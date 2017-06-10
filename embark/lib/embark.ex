defmodule Embark do
  @version Mix.Project.config[:version]
  def version, do: @version

  @template_dir Path.join(__DIR__, "templates")
  def template_dir, do: @template_dir
end
