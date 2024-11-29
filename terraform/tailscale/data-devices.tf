data "tailscale_device" "jack-iphone" {
  name     = "jack-iphone.tortoise-noodlefish.ts.net"
  wait_for = "60s"
}

data "tailscale_device" "lapis" {
  name     = "lapis.tortoise-noodlefish.ts.net"
  wait_for = "60s"
}
