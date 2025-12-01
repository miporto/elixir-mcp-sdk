defmodule MCP.Protocol.NotificationTest do
  use ExUnit.Case, async: true

  alias MCP.Protocol.Notification

  describe "new/2" do
    test "creates a notification with params" do
      notification = Notification.new("progress", %{"value" => 50})

      assert notification.method == "progress"
      assert notification.params == %{"value" => 50}
    end

    test "creates a notification with default empty params" do
      notification = Notification.new("initialized")

      assert notification.method == "initialized"
      assert notification.params == %{}
    end
  end

  describe "parse/1" do
    test "parses a valid notification" do
      message = %{
        "jsonrpc" => "2.0",
        "method" => "notifications/initialized"
      }

      assert {:ok, notification} = Notification.parse(message)
      assert notification.method == "notifications/initialized"
      assert notification.params == %{}
    end

    test "parses a notification with params" do
      message = %{
        "jsonrpc" => "2.0",
        "method" => "progress",
        "params" => %{"value" => 75}
      }

      assert {:ok, notification} = Notification.parse(message)
      assert notification.method == "progress"
      assert notification.params == %{"value" => 75}
    end

    test "rejects notification with id field" do
      message = %{
        "jsonrpc" => "2.0",
        "id" => 1,
        "method" => "test"
      }

      assert {:error, :notification_has_id} = Notification.parse(message)
    end

    test "rejects missing method" do
      message = %{"jsonrpc" => "2.0"}
      assert {:error, :invalid_notification} = Notification.parse(message)
    end

    test "rejects non-string method" do
      message = %{"jsonrpc" => "2.0", "method" => 123}
      assert {:error, :invalid_notification} = Notification.parse(message)
    end
  end

  describe "to_map/1" do
    test "converts notification to map with params" do
      notification = Notification.new("test", %{"key" => "value"})
      map = Notification.to_map(notification)

      assert map == %{
               "jsonrpc" => "2.0",
               "method" => "test",
               "params" => %{"key" => "value"}
             }
    end

    test "omits params when empty" do
      notification = Notification.new("initialized")
      map = Notification.to_map(notification)

      refute Map.has_key?(map, "params")
    end
  end

  describe "encode/1" do
    test "encodes notification to JSON string" do
      notification = Notification.new("test")
      assert {:ok, json} = Notification.encode(notification)
      decoded = :json.decode(json)
      assert decoded["jsonrpc"] == "2.0"
      assert decoded["method"] == "test"
      refute Map.has_key?(decoded, "id")
    end
  end
end
