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
    this.svgClass = options['svgClass']
    this.circleRange = options['circleRange'] || [3, 25]
    this.width = 930 - this.margin.left - this.margin.right
  }

  get svg() {
    return d3.select("svg.timeline")
      .classed(this.svgClass, true)
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

    const groups = g
      .selectAll("g")
      .data(this.data)
      .enter()
      .append("g")
      .attr("class", "a8-code-value")
      .attr('transform', (d, i) => `translate(0, ${i * this.rowHeight + this.standoffAxis} )` )
      .on("mouseenter", this.onMouseEnter.bind(this))
      .on("mouseleave", this.onMouseLeave.bind(this))

    this.drawExtentLines(groups, x)

    groups
      .append("rect")
      .attr('class', 'highlight')
      .attr('x', 0)
      .attr('y', this.rowHeight / 4)
      .attr('width', this.width)
      .attr('height', this.rowHeight + this.rowHeight / 5)

    let row = -1
    groups
      .selectAll('circle')
      .data(function(d) { return d.data })
      .enter()
      .append('circle')
      .attr('class', 'a8-count')
      .attr('cx', (d) => x(new Date(d[0])))
      .attr('cy', this.rowHeight)
      .attr('r', (d) => size(d[1]))
      .attr('fill', function(d,i) {
        if (i === 0) row += 1
        return color(row)
      })
      .append("svg:title")
      .text((d) => `${d[0]}: ${d[1]}`);

    groups
      .append('text')
      .attr('class', 'value')
      .attr("y", () => this.rowHeight)
      .text((d) => d.name);

    g.call(d3.axisTop(x));

    groups.append('svg:title').text((d) => d.name)
    this.groups = groups
  }

  drawExtentLines(groups, x, endHeight= 16) {
    // Extent lines
    groups
      .append("line")
      .data(this.seriesDateExtents())
      .attr("x1", (d) => x(d[0]))
      .attr("y1", this.rowHeight)
      .attr("x2", (d) => x(d[1]))
      .attr("y2", this.rowHeight)

    groups
      .append("line")
      .data(this.seriesDateExtents())
      .attr("x1", (d) => x(d[0]))
      .attr("y1", this.rowHeight + endHeight / 2)
      .attr("x2", (d) => x(d[0]))
      .attr("y2", this.rowHeight - endHeight / 2)

    groups
      .append("line")
      .data(this.seriesDateExtents())
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

  // Transform a point expressed in our SVG viewBox co-ordinates to screen co-ordinates.
  // Used to move the HTML tooltip around over svg objects
  svgToScreen(svgX, svgY) {
    const svgNode = this.svg.node()
    const matrix = svgNode.getCTM();

    const point = svgNode.createSVGPoint();
    point.x = svgX;
    point.y = svgY;

    // now position var will contain screen coordinates:
    return point.matrixTransform(matrix);
  }

  onMouseEnter(d, i) {
    const dateExtents = this.seriesDateExtents()[i]

    const svgX = this.width / 2 + this.margin.left
    const svgY = i * this.rowHeight + this.margin.top + this.standoffAxis + this.rowHeight;

    const position = this.svgToScreen(svgX, svgY)

    this.tooltip.style("transform", `
      translate(calc(
        -50% + ${position.x}px),
        calc(-100% + ${position.y}px
      ))
    `);
    this.tooltip.select("#value")
      .text(d.name);
    this.tooltip.select("#value_name")
      .text(d.value_name);
    this.tooltip.select("#count")
      .text(`First seen ${this.formatDate(dateExtents[0])}, last seen ${this.formatDate(dateExtents[1])}`);
    this.tooltip.style("opacity", 1);
    this.groups.filter((d,j) => i === j)
      .classed('active', true)
  }

  onMouseLeave(d, i) {
    this.tooltip.style("opacity", 0);
    this.groups.filter((d,j) => i === j)
      .classed('active', false)
  }

  get tooltip() {
    if(this._tooltip) return this._tooltip

    this._tooltip = d3.create("div")
      .attr("id", "tooltip")
      .attr("class", "tooltip")
      .html(`
        <div class="tooltip-name">
          <span id="value" class="badge badge-primary"></span>
          <span id="value_name"></span>
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

