export const InfiniteScroll = {
  scrollAt() {
    let scrollTop = document.documentElement.scrollTop || document.body.scrollTop
    let scrollHeight = document.documentElement.scrollHeight || document.body.scrollHeight
    let clientHeight = document.documentElement.clientHeight

    return scrollTop / (scrollHeight - clientHeight) * 100
  },
  offset() { return this.el.dataset.offset },
  mounted() {
    this.pending = this.offset()
    window.addEventListener("scroll", e => {
      if(this.offset && this.pending == this.offset() && this.scrollAt() > 90){
        this.pushEvent("load-more", {})
      }
    })
  },
  updated() { this.pending = this.offset() }
}
