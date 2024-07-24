data "tailscale_device" "ada" {
  name     = "ada.tortoise-noodlefish.ts.net"
  wait_for = "60s"
}

data "tailscale_device" "mba" {
  name     = "mba.tortoise-noodlefish.ts.net"
  wait_for = "60s"
}

data "tailscale_device" "jack-iphone" {
  name     = "jack-iphone.tortoise-noodlefish.ts.net"
  wait_for = "60s"
}
