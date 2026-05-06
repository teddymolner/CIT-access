require("d3")

d3.selectAll("svg > *").remove();

let current_state = 0;
let zoomScale = 0.5;

const RUN_TIME_LABEL = "";

const WIDTH = 1600;
const HEIGHT = 950;

const MIN_ZOOM = 0.5;
const MAX_ZOOM = 2.5;
const ZOOM_STEP = 0.2;

const MAP_CENTER_X = 900;
const MAP_CENTER_Y = 500;

function clean(x) {
  return x.toString().replace(/\[|\]/g, "");
}

// Forge names atoms like Lobby_F20 for the 0th atom of Lobby_F2.
// Strip only a trailing 0, which is the instance suffix.
function canon(x) {
  return clean(x).replace(/0$/, "");
}

function oneName(x) {
  if (x && typeof x.tuples === "function") {
    const ts = x.tuples();
    if (ts.length > 0) return canon(ts[0].atoms()[0]);
  }
  return canon(x);
}

function prettyRoom(name) {
  name = canon(name);

  if (name === "Sciences_Park") return "Sciences Park";

  const lobbyMatch = name.match(/^Lobby_F(\d+)/);
  if (lobbyMatch) return `Lobby F${lobbyMatch[1]}`;

  const roomMatch = name.match(/^Room(\d+)/);
  if (roomMatch) return `Room ${roomMatch[1]}`;

  return name.replaceAll("_", " ");
}

function prettyAccess(name) {
  return canon(name).replaceAll("_", " ");
}

function floorOf(roomName) {
  roomName = canon(roomName);

  if (roomName === "Sciences_Park") return 1;

  const lobbyMatch = roomName.match(/^Lobby_F(\d+)/);
  if (lobbyMatch) return parseInt(lobbyMatch[1]);

  const roomMatch = roomName.match(/^Room(\d+)/);
  if (roomMatch) return parseInt(roomMatch[1][0]);

  return 1;
}

function roomSort(a, b) {
  function key(r) {
    r = canon(r);
    if (r === "Sciences_Park") return [0, 0];
    if (r.startsWith("Lobby_F")) return [1, floorOf(r)];
    const roomMatch = r.match(/^Room(\d+)/);
    if (roomMatch) return [2, parseInt(roomMatch[1])];
    return [3, r];
  }

  const ka = key(a);
  const kb = key(b);

  if (ka[0] !== kb[0]) return ka[0] - kb[0];
  if (ka[1] < kb[1]) return -1;
  if (ka[1] > kb[1]) return 1;
  return 0;
}

function locAt(i) {
  return oneName(instances[i].atom("Person0").loc);
}

function levelName() {
  return prettyAccess(oneName(instances[0].atom("Person0").level));
}

function allRooms() {
  return Room.atoms(true).map(r => canon(r)).sort(roomSort);
}

function buildPositions() {
  const rooms = allRooms();
  const pos = {};
  const floorRows = { 1: [], 2: [], 3: [], 4: [], 5: [] };
  let sciencesPark = null;

  rooms.forEach(r => {
    if (r === "Sciences_Park") {
      sciencesPark = r;
    } else {
      const f = floorOf(r);
      if (!floorRows[f]) floorRows[f] = [];
      floorRows[f].push(r);
    }
  });

  Object.keys(floorRows).forEach(f => floorRows[f].sort(roomSort));

  const rowY = {
    5: 130,
    4: 270,
    3: 410,
    2: 550,
    1: 690
  };

  for (let f = 1; f <= 5; f++) {
    const row = floorRows[f] || [];
    const n = row.length;
    if (n === 0) continue;

    const usableWidth = 1050;
    const spacing = n === 1 ? 0 : Math.min(120, usableWidth / (n - 1));
    const totalWidth = spacing * (n - 1);
    const x0 = 360 - totalWidth / 2;

    row.forEach((room, idx) => {
      pos[room] = {
        x: x0 + idx * spacing,
        y: rowY[f]
      };
    });
  }

    if (sciencesPark) {
    const lobbyF1 = pos["Lobby_F1"];
    if (lobbyF1) {
      pos[sciencesPark] = {
        x: lobbyF1.x,
        y: lobbyF1.y + 110
      };
    } else {
      pos[sciencesPark] = { x: 120, y: rowY[1] + 110 };
    }
  }

  return pos;
}

function normalizeEdge(a, b) {
  a = canon(a);
  b = canon(b);
  return a < b ? `${a}|||${b}` : `${b}|||${a}`;
}

function splitEdge(key) {
  return key.split("|||");
}

function pathEdges() {
  const seen = new Set();
  for (let i = 0; i < instances.length - 1; i++) {
    const a = locAt(i);
    const b = locAt(i + 1);
    if (a !== b) seen.add(normalizeEdge(a, b));
  }
  return Array.from(seen);
}

function currentEdge() {
  if (current_state >= instances.length - 1) return null;
  const a = locAt(current_state);
  const b = locAt(current_state + 1);
  if (a === b) return null;
  return normalizeEdge(a, b);
}

function mapTransform() {
  return `translate(${MAP_CENTER_X},${MAP_CENTER_Y}) scale(${zoomScale}) translate(${-MAP_CENTER_X},${-MAP_CENTER_Y})`;
}

function drawButton(root, label, x, y, w, h, onClick) {
  root.append("rect")
    .attr("x", x)
    .attr("y", y)
    .attr("width", w)
    .attr("height", h)
    .attr("rx", 8)
    .attr("ry", 8)
    .attr("fill", "#efefef")
    .attr("stroke", "#666")
    .style("cursor", "pointer")
    .on("click", onClick);

  root.append("text")
    .attr("x", x + w / 2)
    .attr("y", y + h / 2 + 6)
    .attr("text-anchor", "middle")
    .style("font", "18px sans-serif")
    .style("cursor", "pointer")
    .text(label)
    .on("click", onClick);
}

function render() {
  d3.selectAll("svg > *").remove();

  d3.select(svg)
    .attr("viewBox", `0 0 ${WIDTH} ${HEIGHT}`);

  const root = d3.select(svg);
  const pos = buildPositions();
  const rooms = allRooms();
  const usedEdges = pathEdges();
  const activeEdge = currentEdge();
  const currentRoom = locAt(current_state);

  // top-left info
  root.append("text")
    .attr("x", 25)
    .attr("y", 35)
    .style("font", "22px sans-serif")
    .style("font-weight", "bold")
    .text(`Access Level: ${levelName()}`);

  root.append("text")
    .attr("x", 25)
    .attr("y", 65)
    .style("font", "22px sans-serif")
    .style("font-weight", "bold")
    .text(`Access Time: ${RUN_TIME_LABEL}`);

  root.append("text")
    .attr("x", 25)
    .attr("y", 100)
    .style("font", "18px sans-serif")
    .text(`State: ${current_state} / ${instances.length - 1}`);

  root.append("text")
    .attr("x", 25)
    .attr("y", 128)
    .style("font", "18px sans-serif")
    .text(`Current Room: ${prettyRoom(currentRoom)}`);

  root.append("text")
    .attr("x", 25)
    .attr("y", 156)
    .style("font", "16px sans-serif")
    .style("fill", "#555")
    .text(`Zoom: ${zoomScale.toFixed(1)}x`);

  // controls
  drawButton(root, "Previous", 25, 190, 110, 38, () => {
    if (current_state > 0) {
      current_state--;
      render();
    }
  });

  drawButton(root, "Next", 145, 190, 90, 38, () => {
    if (current_state < instances.length - 1) {
      current_state++;
      render();
    }
  });

  drawButton(root, "Zoom In", 25, 240, 100, 38, () => {
    zoomScale = Math.min(MAX_ZOOM, zoomScale + ZOOM_STEP);
    render();
  });

  drawButton(root, "Zoom Out", 135, 240, 110, 38, () => {
    zoomScale = Math.max(MIN_ZOOM, zoomScale - ZOOM_STEP);
    render();
  });

  // map container
  const map = root.append("g")
    .attr("transform", mapTransform());

  // floor guides
  [5, 4, 3, 2, 1].forEach(f => {
    const y = {5:130, 4:270, 3:410, 2:550, 1:690}[f];

    map.append("line")
      .attr("x1", 40)
      .attr("y1", y)
      .attr("x2", 1480)
      .attr("y2", y)
      .attr("stroke", "#f0f0f0")
      .attr("stroke-width", 2);

    map.append("text")
      .attr("x", 1500)
      .attr("y", y + 6)
      .attr("text-anchor", "end")
      .style("font", "18px sans-serif")
      .style("fill", "#888")
      .text(`Floor ${f}`);
  });

  // path-used edges
  usedEdges.forEach(edgeKey => {
    const [a, b] = splitEdge(edgeKey);
    if (!pos[a] || !pos[b]) return;

    map.append("line")
      .attr("x1", pos[a].x)
      .attr("y1", pos[a].y)
      .attr("x2", pos[b].x)
      .attr("y2", pos[b].y)
      .attr("stroke", edgeKey === activeEdge ? "#ff8c00" : "#5b8ff9")
      .attr("stroke-width", edgeKey === activeEdge ? 10 : 6)
      .attr("stroke-linecap", "round")
      .attr("opacity", edgeKey === activeEdge ? 0.95 : 0.55);
  });

  // room nodes
  rooms.forEach(room => {
    if (!pos[room]) return;

    const isCurrent = room === currentRoom;
    const isLobby = room.startsWith("Lobby_F");
    const radius = isLobby ? 32 : 24;

    map.append("circle")
      .attr("cx", pos[room].x)
      .attr("cy", pos[room].y)
      .attr("r", radius)
      .attr("fill", isCurrent ? "#ffcc66" : (isLobby ? "#d9ead3" : "#e6e6e6"))
      .attr("stroke", isCurrent ? "#cc7a00" : "#555")
      .attr("stroke-width", isCurrent ? 4 : 2);

    map.append("text")
      .attr("x", pos[room].x)
      .attr("y", pos[room].y + radius + 18)
      .attr("text-anchor", "middle")
      .style("font", room.startsWith("Room") ? "12px sans-serif" : "14px sans-serif")
      .text(prettyRoom(room));
  });

  // person marker
  if (pos[currentRoom]) {
    map.append("text")
      .attr("x", pos[currentRoom].x)
      .attr("y", pos[currentRoom].y + 8)
      .attr("text-anchor", "middle")
      .style("font", "22px sans-serif")
      .text("🧍");
  }

  // legend
  root.append("circle")
    .attr("cx", 35)
    .attr("cy", 330)
    .attr("r", 9)
    .attr("fill", "#ffcc66")
    .attr("stroke", "#cc7a00");

  root.append("text")
    .attr("x", 52)
    .attr("y", 336)
    .style("font", "15px sans-serif")
    .text("Current room");

  root.append("line")
    .attr("x1", 27)
    .attr("y1", 358)
    .attr("x2", 43)
    .attr("y2", 358)
    .attr("stroke", "#5b8ff9")
    .attr("stroke-width", 6)
    .attr("stroke-linecap", "round")
    .attr("opacity", 0.55);

  root.append("text")
    .attr("x", 52)
    .attr("y", 363)
    .style("font", "15px sans-serif")
    .text("Door used somewhere in path");

  root.append("line")
    .attr("x1", 27)
    .attr("y1", 385)
    .attr("x2", 43)
    .attr("y2", 385)
    .attr("stroke", "#ff8c00")
    .attr("stroke-width", 8)
    .attr("stroke-linecap", "round");

  root.append("text")
    .attr("x", 52)
    .attr("y", 390)
    .style("font", "15px sans-serif")
    .text("Current move");
}

render();