// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"
import {InfiniteScroll} from "./infinite_scroll"

let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {hooks: {InfiniteScroll}, params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})

// This isn't working, just disable the loading bar for now
// let topBarScheduled = undefined
//
// window.addEventListener("phx:page-loading-start", () => {
  // if(!topBarScheduled) {
    // topBarScheduled = setTimeout(() => topbar.show(), 30)
  // }
// })
//
// window.addEventListener("phx:page-loading-stop", () => {
  // clearTimeout(topBarScheduled)
  // topBarScheduled = undefined
  // topbar.hide()
// })

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket
