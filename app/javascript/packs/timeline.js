import * as d3 from "d3"

class Timeline {
  /*
    data is of form: [
      { name: 'cardt', data: [['2020-08-03', 1354], ['2020-08-04', 442]] },
      { name: 'julyeom', data: [['2020-08-02', 2], ['2020-08-06', 12]] },
    ]
   */
  constructor(data, options = {}) {
    this.data = data
    this.rowHeight = options['rowHeight'] || 32
    this.margin = { top: 32, right: 32, bottom: 32, left: 32 }
    this.standoffAxis = this.margin.top
    this.circleRange = options['circleRange'] || [3, 25]
    this.width = this.svg.style('width').replace('px', '') - this.margin.left - this.margin.right
  }

  get svg() {
    return d3.select("svg.timeline")
  }

  /* [min,max] of each series */
  seriesDateExtents() {
    return this.data.map((series) => d3.extent(
      series.data.map( (dateCounts) => new Date(dateCounts[0]) ) )
    )
  }

  overallDateExtents() {
    const seriesExtents = this.seriesDateExtents()
    const min = d3.min(seriesExtents.map((a) => a[0]))
    const max = d3.max(seriesExtents.map((a) => a[1]))

    return [min, max]
  }

  /* [min,max] of each series's count */
  seriesCountExtents() {
    return this.data.map((series) => d3.extent(
      series.data.map( (dateCounts) => new Date(dateCounts[1]) ) )
    )
  }

  overallSeriesExtents() {
    const seriesExtents = this.seriesCountExtents()
    const min = d3.min(seriesExtents.map((a) => a[0]))
    const max = d3.max(seriesExtents.map((a) => a[1]))

    return [min, max]
  }

  get x() {
    if(this._x) return this._x

    this._x = d3.scaleTime().domain(this.overallDateExtents()).range([0, this.width])
    return this._x
  }

  draw() {
    const svg = this.svg
    const x = this.x
    const size = d3.scaleLinear().domain(this.overallSeriesExtents()).range(this.circleRange);
    const color = d3.scaleOrdinal().range(d3.schemeSpectral[11]).domain(this.data.length)

    const g = svg.append("g")
      .attr("transform", `translate(${this.margin.left},${this.margin.top })`)

    const audiences = g
      .selectAll("g")
      .data(this.data)
      .enter()
      .append("g")
      .attr("class", "audience")
      .attr('transform', (d, i) => `translate(0, ${i * this.rowHeight + this.standoffAxis} )` )
      .on("mouseenter", this.onMouseEnter.bind(this))
      .on("mouseleave", this.onMouseLeave.bind(this))

    this.drawExtentLines(audiences, x)

    audiences
      .append("rect")
      .attr('class', 'highlightRect')
      .attr('x', 0)
      .attr('y', 0)
      .attr('width', this.width)
      .attr('height', this.rowHeight * 2)
      .attr('opacity', '0')
      .attr('fill', 'gray')

    let row = -1
    audiences
      .selectAll('circle')
      .data(function(d) { return d.data })
      .enter()
      .append('circle')
      .attr('cx', (d) => x(new Date(d[0])))
      .attr('cy', this.rowHeight)
      .attr('stroke', 'black')
      .attr('opacity', '0.9')
      .attr('r', (d) => size(d[1]))
      .attr('fill', function(d,i) {
        if (i === 0) row += 1
        return color(row)
      })
      .append("svg:title")
      .text((d) => `${d[0]}: ${d[1]}`);

    g.call(d3.axisTop(x));

    audiences.append('svg:title').text((d) => d.name)
  }

  drawExtentLines(audiences, x, endHeight= 16) {
    // Extent lines
    audiences
      .append("line")
      .data(this.seriesDateExtents())
      .style("stroke", "silver")
      .attr("x1", (d) => x(d[0]))
      .attr("y1", this.rowHeight)
      .attr("x2", (d) => x(d[1]))
      .attr("y2", this.rowHeight)

    audiences
      .append("line")
      .data(this.seriesDateExtents())
      .style("stroke", "silver")
      .attr("x1", (d) => x(d[0]))
      .attr("y1", this.rowHeight + endHeight / 2)
      .attr("x2", (d) => x(d[0]))
      .attr("y2", this.rowHeight - endHeight / 2)

    audiences
      .append("line")
      .data(this.seriesDateExtents())
      .style("stroke", "silver")
      .attr("x1", (d) => x(d[1]))
      .attr("y1", this.rowHeight + endHeight / 2)
      .attr("x2", (d) => x(d[1]))
      .attr("y2", this.rowHeight - endHeight / 2)
  }

  formatDate(date) {
    let d = new Date(date),
      month = '' + (d.getMonth() + 1),
      day = '' + d.getDate(),
      year = d.getFullYear();

    if (month.length < 2)
      month = '0' + month;
    if (day.length < 2)
      day = '0' + day;

    return [year, month, day].join('-');
  }

  onMouseEnter(d, i) {
    const dateExtents = this.seriesDateExtents()[i]

    this.tooltip.style("opacity", 1);
    this.tooltip.style("transform", `
      translate(calc( 
        -50% + ${this.width / 2 + this.margin.left}px), 
        calc(-100% + ${i * this.rowHeight + this.margin.top + this.standoffAxis + this.rowHeight}px
      ))
    `);
    this.tooltip.select("#value")
      .text(d.name);
    this.tooltip.select("#count")
      .text(`First seen ${this.formatDate(dateExtents[0])}, last seen ${this.formatDate(dateExtents[1])}`);
  }

  onMouseLeave() {
    this.tooltip.style("opacity", 0);
  }


  get tooltip() {
    if(this._tooltip) return this._tooltip

    this._tooltip = d3.create("div")
      .attr("id", "tooltip")
      .attr("class", "tooltip")
      .html(`
        <div class="tooltip-name">
          <span id="value"></span>
        </div>
        <div class="tooltip-value">
          <span id="count"></span>
        </div>
      `);

    const svg = document.querySelector('svg.timeline')
    svg.parentNode.insertBefore(this._tooltip.node(), svg);

    return this._tooltip
  }
}

export { Timeline }
window.Timeline = Timeline

