defmodule Tokumei.TemplateTest do
  use ExUnit.Case

  use Tokumei.Templates, at: "./templates"

  test "Content is interpolated" do
    %{body: body} = render("example.txt", content: "hi")
    assert body == "content: hi\n"
  end

  test "Mime type is set for text files" do
    %{headers: headers} = render("example.txt", content: "hi")
    assert headers == [{"content-type", "text/plain"}]
  end

  test "Mime type is set for html files" do
    %{headers: headers} = render("example.html", content: "hi")
    assert headers == [{"content-type", "text/html"}]
  end
end
