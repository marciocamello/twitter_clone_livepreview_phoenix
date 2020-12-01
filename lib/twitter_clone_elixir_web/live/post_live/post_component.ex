defmodule TwitterCloneElixirWeb.PostLive.PostComponent do
  use TwitterCloneElixirWeb, :live_component

  def render(assigns) do
    ~L"""
      <div id="post-<%= @post.id %>" class="post">
        <div class="row">
          <div class="column column-10">
            <div class="post-avatar">
              <img src="https://via.placeholder.com/100" alt="<%= @post.username %>">
            </div>
          </div>
          <div class="column column-90 post-body">
            <b>@<%= @post.username %></b>
            <br />
            <%= @post.body %>
          </div>
        </div>
        <div class="row">
          <div class="column column-33 text-center">
            <a href="#" phx-click="like" phx-target="<%= @myself %>">
              <i class="fas fa-heart"></i> <%= @post.likes_count %>
            </a>
          </div>
          <div class="column column-33 text-center">
            <a href="#" phx-click="repost" phx-target="<%= @myself %>">
              <i class="fas fa-retweet"></i> <%= @post.reposts_count %>
            </a>
          </div>
          <div class="column column-33 text-center">
            <%= live_patch to: Routes.post_index_path(@socket, :edit, @post.id) do %>
              <i class="fas fa-edit"></i>
            <% end %>
            <span>&nbsp;&nbsp;</span>
            <%= link to: "#", phx_click: "delete", phx_value_id: @post.id, data: [confirm: "Are you sure?"] do %>
              <i class="fas fa-trash-alt"></i>
            <% end %>
          </div>
        </div>
      </div>
     """
  end

  def handle_event("like", _, socket) do
    TwitterCloneElixir.Timeline.inc_likes(socket.assigns.post)
    {:noreply, socket}
  end

  def handle_event("repost", _, socket) do
    TwitterCloneElixir.Timeline.inc_reposts(socket.assigns.post)
    {:noreply, socket}
  end
end
