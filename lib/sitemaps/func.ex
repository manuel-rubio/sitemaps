defmodule Sitemaps.Func do
  @moduledoc """
  Func is that module that is usually called utils, common, or another name
  you can figure it out where you have not to think about to put whatever
  function you don't know where to put.

  Of course, it should be moved to other modules with better names, but at
  the moment, here they are.
  """

  #  TODO move functions to meaningful names

  @doc """
  Convert the different information about date and times to ISO-8601 format.
  """
  def iso8601(year, month, day, hour, minute, second) do
    NaiveDateTime.new!(year, month, day, hour, minute, second)
    |> iso8601()
  end

  def iso8601 do
    DateTime.utc_now(:second)
    |> iso8601()
  end

  def iso8601({{year, month, day}, {hour, minute, second}}) do
    iso8601(year, month, day, hour, minute, second)
  end

  def iso8601(%NaiveDateTime{} = datetime) do
    NaiveDateTime.truncate(datetime, :second)
    |> DateTime.from_naive!("Etc/UTC")
    |> iso8601()
  end

  def iso8601(%DateTime{} = datetime) do
    datetime
    |> DateTime.truncate(:second)
    |> DateTime.to_iso8601()
  end

  def iso8601(%Date{} = date) do
    Date.to_iso8601(date)
  end

  def iso8601(datetime), do: datetime

  @doc """
  Remove useless tags or content from the list of XML.
  """
  def eraser(elements) do
    Enum.filter(elements, fn
      el when is_list(el) -> eraser(el)
      nil -> false
      el -> !!elem(el, 2)
    end)
  end

  @doc """
  Convert boolean value to the string: yes or no.
  """
  @spec yes_no(boolean()) :: String.t()
  def yes_no(false), do: "no"
  def yes_no(_), do: "yes"

  @doc """
  Convert boolean value to the string: deny or allow.
  """
  @spec allow_deny(boolean()) :: String.t()
  def allow_deny(false), do: "deny"
  def allow_deny(_), do: "allow"

  @doc """
  Convert if the parameter received is truthy value to ap=1,
  otherwise ap=0.
  """
  @spec autoplay(any()) :: String.t()
  def autoplay(bool) do
    if bool, do: "ap=1", else: "ap=0"
  end

  @doc """
  Get the environment variable passed as parameter. If the value is
  false or true text it will be converted as boolean. If the value
  could be a number, it's converted to an integer otherwise it's
  kept as strings or nil.
  """
  @spec get_env(String.t()) :: boolean() | nil | integer() | String.t()
  def get_env(key) do
    value = System.get_env(key)

    cond do
      value == "false" ->
        false

      value == "true" ->
        true

      numeric?(value) ->
        {num, _} = Integer.parse(value)
        num

      :else ->
        value
    end
  end

  @doc """
  Concrete if the value is a number or not.
  """
  @spec numeric?(nil | String.t()) :: boolean()
  def numeric?(nil), do: false

  def numeric?(str) do
    case Float.parse(str) do
      {_num, ""} -> true
      {_num, _r} -> false
      :error -> false
    end
  end

  @doc """
  Join URI data from the two URIs passed as parameters.
  """
  @spec url_join(String.t() | URI.t(), String.t() | URI.t()) :: String.t()
  def url_join(src, dest) do
    src = URI.parse(src)
    dest = URI.parse(dest)

    %{
      host: dest.host || src.host,
      path: dest.path || src.path,
      port: dest.port || src.port,
      query: dest.query || src.query,
      scheme: dest.scheme || src.scheme,
      userinfo: dest.userinfo || src.userinfo,
      fragment: dest.fragment || src.fragment
    }
    |> then(&struct(URI, &1))
    |> to_string()
  end
end
