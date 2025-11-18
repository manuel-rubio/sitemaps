defmodule Sitemap.State do
  @moduledoc """
  Creates a state for the modules that use this module.
  """

  defmacro __using__(opts) do
    quote do
      use Agent

      @typedoc false
      @type t() :: %__MODULE__{}

      defstruct unquote(opts)
      @__struct_resource__ unquote(opts)

      defp namepid(name),
        do: String.to_atom(Enum.join([__MODULE__, name]))

      @doc false
      def start_link, do: start_link("", [])
      def start_link(opts) when is_list(opts), do: start_link("", opts)
      def start_link(name), do: start_link(name, [])

      def start_link(name, opts) do
        Agent.start_link(fn -> struct(__MODULE__, opts) end, name: namepid(name))
      end

      @doc false
      def state(name \\ ""), do: Agent.get(namepid(name), & &1)

      @doc false
      def stop(name \\ "") do
        Agent.update(namepid(name), fn _ ->
          %__MODULE__{}
        end)
      end

      @doc false
      def add_state(key, xml), do: add_state("", key, xml)

      @doc false
      def add_state(name, key, xml) do
        Agent.update(namepid(name), fn s ->
          Map.update!(s, key, &(&1 <> xml))
        end)
      end

      @doc false
      def update_state(key, xml), do: update_state("", key, xml)

      @doc false
      def update_state(name, key, xml) do
        Agent.update(namepid(name), fn s ->
          Map.update!(s, key, fn _ -> xml end)
        end)
      end

      @doc false
      def incr_state(key), do: incr_state("", key, 1)
      def incr_state(key, number) when is_number(number), do: incr_state("", key, number)
      def incr_state(name, key), do: incr_state(name, key, 1)

      def incr_state(name, key, number) do
        Agent.update(namepid(name), fn s ->
          Map.update!(s, key, &((&1 || 0) + number))
        end)
      end

      @doc false
      def decr_state(key), do: decr_state("", key, 1)
      def decr_state(key, number) when is_number(number), do: decr_state("", key, 1)
      def decr_state(name, key), do: decr_state(name, key, 1)

      def decr_state(name, key, number) do
        Agent.update(namepid(name), fn s ->
          Map.update!(s, key, &((&1 || 0) - number))
        end)
      end
    end
  end
end
