defmodule TwitterCloneElixirWeb.PostLive.FormComponent do
  use TwitterCloneElixirWeb, :live_component

  alias TwitterCloneElixir.Timeline
  alias TwitterCloneElixir.Timeline.Post

  @impl true
  @spec mount(Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(socket) do
    {:ok,
     allow_upload(socket, :photo,
       accept: ~w(.png .jpeg .jpg),
       max_entries: 2,
       max_file_size: 50_000,
       external: &presign_entry/2
     )}
  end

  @impl true
  def update(%{post: post} = assigns, socket) do
    changeset = Timeline.change_post(post)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)}
  end

  @impl true
  def handle_event("validate", %{"post" => post_params}, socket) do
    changeset =
      socket.assigns.post
      |> Timeline.change_post(post_params)
      |> Map.put(:action, :validate)

    {:noreply, assign(socket, :changeset, changeset)}
  end

  def handle_event("save", %{"post" => post_params}, socket) do
    save_post(socket, socket.assigns.action, post_params)
  end

  def handle_event("cancel-entry", %{"ref" => ref}, socket) do
    {:noreply, cancel_upload(socket, :photo, ref)}
  end

  defp save_post(socket, :edit, post_params) do
    post = put_photo_urls(socket, socket.assigns.post)

    case Timeline.update_post(post, post_params, &consume_photos(socket, &1)) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post updated successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, :changeset, changeset)}
    end
  end

  defp save_post(socket, :new, post_params) do
    post = put_photo_urls(socket, %Post{})

    case Timeline.create_post(post, post_params, &consume_photos(socket, &1)) do
      {:ok, _post} ->
        {:noreply,
         socket
         |> put_flash(:info, "Post created successfully")
         |> push_redirect(to: socket.assigns.return_to)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign(socket, changeset: changeset)}
    end
  end

  def ext(entry) do
    [ext | _] = MIME.extensions(entry.client_type)
    ext
  end

  defp put_photo_urls(socket, %Post{} = post) do
    {completed, []} = uploaded_entries(socket, :photo)

    urls =
      for entry <- completed do
        Path.join(s3_host(), s3_key(entry))
      end

    %Post{post | photo_urls: urls}
  end

  def consume_photos(socket, %Post{} = post) do
    consume_uploaded_entries(socket, :photo, fn %{} = meta, _entry ->
      {:ok, presigned_url} =
        ExAws.Config.new(:s3)
        |> ExAws.S3.presigned_url(:get, meta.bucket, meta.key, expires_in: 86_400)

      presigned_url
    end)

    {:ok, post}
  end

  @bucket "twitter-clone-s3"
  defp s3_host, do: "//#{@bucket}.s3.amazonaws.com"
  defp s3_key(entry), do: "#{entry.uuid}.#{ext(entry)}"

  defp presign_entry(entry, socket) do
    key = s3_key(entry)

    {:ok, presigned_url} = ExAws.Config.new(:s3) |> ExAws.S3.presigned_url(:put, @bucket, key)
    meta = %{uploader: "S3", bucket: @bucket, key: key, url: presigned_url}
    {:ok, meta, socket}
  end
end
