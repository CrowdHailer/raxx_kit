defmodule Fifteen.WWW.Router do
  import Tokumei.Router
  alias Tokumei.Router.{NotImplementedError, MethodNotAllowedError, NotFound}
  alias Raxx.Response

  #
  # route "/",
  #   GET: HomePage
  #
  # route "/posts",
  #   GET: ShowPostsPage,
  #   POST: CreatePost
  #
  # route "/posts/:id",
  #   GET: ShowPostPage,
  #   PUT: UpdatePost
  #
  # route "/posts/:id/edit",
  #   GET: EditPostPage

  route "/" do
    :GET -> Response.ok("Hi")
  end

  route "/posts" do
    :GET ->
      page = page_info(request.query)
      posts_page = PostsRepo.fetch_page(page)
      Response.ok(render_post(posts_page))
    :POST ->
      data = Post.CreateForm.validate(request.body)
      post = PostsRepo.insert(data)
      Response.redirect("/posts/#{post.id}")
  end

  route "/posts/:id" do
    :GET ->
      OK.with do
        post <- PostsRepo.fetch_by_id(id)
      end
    :PUT ->
      OK.with do
        data <- PostForm.validate(request.body)
        post <- PostsRepo.fetch_by_id(id)
        updated_post <- Post.update(post, data)
        save_post <- PostsRepo.update(updated_post)
      end
      |> case  do
        {:ok, post} ->
          Response.redirect("/posts/#{post.id}")
        {:error, :post_not_found} ->
          Response.not_found(not_found_page())
        {:error, %Form.ValidationError{}} -?
          Response.bad_request(edit_page())
      end
  end
  route "/posts/:id/edit" do

  end
end
