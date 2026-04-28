require("d3")

let current_state = 0;

function clean(x) {
  return x.toString().replace(/\[|\]/g, "");
}

function locName() {
  return clean(instances[current_state].atom("Person0").loc);
}

const pos = {
  Sciences_Park0: [90, 310],
  Lobby_F10: [240, 310],
  Room1010: [240, 450],

  Lobby_F20: [420, 310],
  Lobby_F30: [580, 230],
  Lobby_F40: [580, 390],
  Lobby_F50: [740, 310],
};

function pretty(room) {
  return room.replace("0", "").replaceAll("_", " ");
}

function drawText(text, x, y, size = 16, fill = "black") {
  return d3.select(svg).append("text")
    .attr("x", x)
    .attr("y", y)
    .attr("text-anchor", "middle")
    .style("font", `${size}px sans-serif`)
    .style("fill", fill)
    .text(text);
}

function render() {
  d3.selectAll("svg > *").remove();

  const current = locName();

  // Draw connections from actual Door atoms
  Door.atoms().forEach(d => {
    const from = clean(d.from);
    const to = clean(d.to);
    if (!pos[from] || !pos[to]) return;

    const [x1, y1] = pos[from];
    const [x2, y2] = pos[to];

    d3.select(svg).append("line")
      .attr("x1", x1)
      .attr("y1", y1)
      .attr("x2", x2)
      .attr("y2", y2)
      .attr("stroke", "#777")
      .attr("stroke-width", 4);
  });

  // Draw rooms
  Object.entries(pos).forEach(([room, [x, y]]) => {
    const here = room === current;

    d3.select(svg).append("circle")
      .attr("cx", x)
      .attr("cy", y)
      .attr("r", 38)
      .attr("fill", here ? "orange" : "#e6e6e6")
      .attr("stroke", here ? "black" : "#555")
      .attr("stroke-width", here ? 4 : 2);

    drawText(pretty(room), x, y + 62, 14);
  });

  // Draw person
  const [px, py] = pos[current];

  drawText("🧍", px, py + 12, 34);

  // Header
  drawText(`State ${current_state} of ${instances.length - 1}`, 410, 40, 22);
  drawText(`Person is in: ${pretty(current)}`, 410, 70, 18);

  // Buttons
  d3.select(svg).append("text")
    .attr("x", 310)
    .attr("y", 560)
    .attr("text-anchor", "middle")
    .style("font", "20px sans-serif")
    .style("fill", "blue")
    .style("cursor", "pointer")
    .text("← Previous")
    .on("click", () => {
      if (current_state > 0) current_state--;
      render();
    });

  d3.select(svg).append("text")
    .attr("x", 510)
    .attr("y", 560)
    .attr("text-anchor", "middle")
    .style("font", "20px sans-serif")
    .style("fill", "blue")
    .style("cursor", "pointer")
    .text("Next →")
    .on("click", () => {
      if (current_state < instances.length - 1) current_state++;
      render();
    });
}

render();