function getRooms() {
  return Room.atoms(true);
}

function getDoors() {
  return Door.atoms(true);
}

function labelAccess(d) {
  const bh = d.join("accessible").join("BusinessHours").atoms(true);
  const wd = d.join("accessible").join("OffHoursWeekday").atoms(true);
  const we = d.join("accessible").join("OffHoursWeekend").atoms(true);

  return `BH:${bh} | WD:${wd} | WE:${we}`;
}

function getKind(d) {
  const k = d.join("kind").atoms(true);
  return k.length ? k[0].toString() : "Door";
}

function buildGraph() {
  let html = `<div style="font-family: monospace">`;
  html += `<h3>CIT Access Graph</h3>`;

  const rooms = getRooms();
  const doors = getDoors();

  rooms.forEach(r => {
    html += `<div style="margin-bottom:12px;">`;
    html += `<b>${r}</b><br/>`;

    doors.forEach(d => {
      const from = d.join("from").atoms(true);
      const to = d.join("to").atoms(true);

      if (from.length && from[0] === r) {
        const kind = getKind(d);
        const access = labelAccess(d);

        html += `→ ${to[0]} 
          <span style="color:gray">
          (${kind} | ${access})
          </span><br/>`;
      }
    });

    html += `</div>`;
  });

  html += `</div>`;
  return html;
}

// render
div.innerHTML = buildGraph();