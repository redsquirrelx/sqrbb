// Datos de ejemplo (podrías reemplazar con fetch a tu API)
const PROPIEDADES = [
  {
    id: 1,
    titulo: "Habitación Individual Deluxe",
    tipo: "habitacion_individual",
    ubicacion: "Centro de la Ciudad",
    descripcion: "Habitación cómoda con todas las comodidades para una persona.",
    precio: 45,
    capacidad: 1,
    amenities: ["wifi","tv","ac"],
    imagen: "https://picsum.photos/seed/room1/800/450",
    disponible: true
  },
  {
    id: 2,
    titulo: "Habitación Doble Premium",
    tipo: "habitacion_doble",
    ubicacion: "Zona Turística",
    descripcion: "Espaciosa habitación con cama matrimonial y vista panorámica.",
    precio: 75,
    capacidad: 2,
    amenities: ["wifi","desayuno","bano"],
    imagen: "https://picsum.photos/seed/room2/800/450",
    disponible: true
  },
  {
    id: 3,
    titulo: "Suite Ejecutiva",
    tipo: "suite",
    ubicacion: "Distrito Financiero",
    descripcion: "Suite de lujo con sala de estar y área de trabajo.",
    precio: 150,
    capacidad: 2,
    amenities: ["wifi","escritorio","minibar"],
    imagen: "https://picsum.photos/seed/room3/800/450",
    disponible: true
  },
  {
    id: 4,
    titulo: "Apartamento Familiar",
    tipo: "apartamento",
    ubicacion: "Zona Residencial",
    descripcion: "Apartamento completo con cocina y 2 habitaciones.",
    precio: 120,
    capacidad: 4,
    amenities: ["cocina","habitaciones","parking"],
    imagen: "https://picsum.photos/seed/room4/800/450",
    disponible: true
  },
  {
    id: 5,
    titulo: "Habitación con Balcón",
    tipo: "habitacion_doble",
    ubicacion: "Vista al Mar",
    descripcion: "Hermosa habitación con balcón privado y vista espectacular.",
    precio: 95,
    capacidad: 2,
    amenities: ["vista","balcon","cafetera","wifi"],
    imagen: "https://picsum.photos/seed/room5/800/450",
    disponible: true
  },
  {
    id: 6,
    titulo: "Habitación Económica",
    tipo: "habitacion_individual",
    ubicacion: "Cerca del Aeropuerto",
    descripcion: "Opción económica con todas las comodidades básicas.",
    precio: 35,
    capacidad: 1,
    amenities: ["wifi","tv","bano"],
    imagen: "https://picsum.photos/seed/room6/800/450",
    disponible: true
  }
];

// Helpers
const qs = (s, el=document) => el.querySelector(s);
const qsa = (s, el=document) => [...el.querySelectorAll(s)];
const $grid = qs("#cardsGrid");
const $count = qs("#resultsCount");
const $form = qs("#filtersForm");
const $toggle = qs("#viewToggle");

function priceBucket(price){
  if (price < 50) return "lt50";
  if (price >= 50 && price <= 100) return "50-100";
  if (price > 100 && price <= 200) return "100-200";
  return "gt200";
}

function capacityBucket(cap){
  if (cap === 1) return "1";
  if (cap === 2) return "2";
  if (cap <= 4) return "3-4";
  return "5+";
}

function applyFilters(list, params){
  const q = (params.get("q") || "").toLowerCase().trim();
  const tipo = params.get("tipo") || "";
  const precio = params.get("precio") || "";
  const capacidad = params.get("capacidad") || "";
  const wifi = params.get("wifi")==="on";
  const desayuno = params.get("desayuno")==="on";
  const ac = params.get("ac")==="on";
  const parking = params.get("parking")==="on";

  let filtered = list.filter(p => {
    if (tipo && p.tipo !== tipo) return false;
    if (precio && priceBucket(p.precio) !== precio) return false;
    if (capacidad && capacityBucket(p.capacidad) !== capacidad) return false;
    if (wifi && !p.amenities.includes("wifi")) return false;
    if (desayuno && !p.amenities.includes("desayuno")) return false;
    if (ac && !p.amenities.includes("ac")) return false;
    if (parking && !p.amenities.includes("parking")) return false;

    if (q){
      const text = `${p.titulo} ${p.ubicacion} ${p.descripcion}`.toLowerCase();
      if (!text.includes(q)) return false;
    }
    return true;
  });

  const sort = params.get("sort") || "relevancia";
  if (sort === "precio_asc") filtered = filtered.sort((a,b) => a.precio - b.precio);
  if (sort === "precio_desc") filtered = filtered.sort((a,b) => b.precio - a.precio);

  return filtered;
}

function cardAmenityIcon(key){
  const map = {
    wifi: "bi-wifi",
    tv: "bi-tv",
    ac: "bi-snow",
    desayuno: "bi-cup-hot",
    bano: "bi-water",
    escritorio: "bi-briefcase",
    minibar: "bi-cup",
    cocina: "bi-house",
    habitaciones: "bi-door-open",
    parking: "bi-p",
    vista: "bi-eye",
    balcon: "bi-door-open",
    cafetera: "bi-cup-hot"
  };
  return map[key] || "bi-check2";
}

function renderCards(list){
  $grid.setAttribute("aria-busy","true");
  $grid.innerHTML = "";

  if (list.length === 0){
    $grid.innerHTML = `
      <div class="col-12">
        <div class="alert alert-light border">
          <i class="bi bi-emoji-frown me-2"></i>No encontramos resultados con esos filtros.
        </div>
      </div>`;
    $count.textContent = "Mostrando 0 propiedades";
    $grid.setAttribute("aria-busy","false");
    return;
  }

  const frag = document.createDocumentFragment();
  list.forEach(p => {
    const col = document.createElement("div");
    col.className = "col-12 col-md-6 col-lg-4 col-card";

    col.innerHTML = `
      <article class="card card-property h-100" data-id="${p.id}">
        <div class="card-media">
          <button class="wishlist" type="button" aria-label="Guardar en favoritos">
            <i class="bi bi-heart"></i>
          </button>
          <img src="${p.imagen}" alt="${p.titulo}" loading="lazy" />
          ${p.disponible ? '<span class="badge-availability">Disponible</span>' : ''}
        </div>
        <div class="card-body">
          <h2 class="card-title h5 mb-1">${p.titulo}</h2>
          <p class="card-location mb-1"><i class="bi bi-geo-alt me-1"></i>${p.ubicacion}</p>
          <p class="mb-2">${p.descripcion}</p>
          <div class="card-amenities mb-2">
            ${p.amenities.slice(0,4).map(a => `<i class="bi ${cardAmenityIcon(a)}" title="${a}"></i>`).join("")}
          </div>
          <div class="card-price">
            <span class="price">$${p.precio}/noche</span>
            <div class="card-cta">
              <a class="btn btn-primary" href="reservas.html?propiedad=${p.id}">Reservar</a>
            </div>
          </div>
        </div>
      </article>
    `;
    frag.appendChild(col);
  });

  $grid.appendChild(frag);
  $count.textContent = `Mostrando ${list.length} ${list.length === 1 ? "propiedad" : "propiedades"}`;
  $grid.setAttribute("aria-busy","false");

  // Toggle favoritos (solo UI)
  qsa(".wishlist", $grid).forEach(btn=>{
    btn.addEventListener("click", ()=>{
      btn.classList.toggle("active");
      const icon = qs("i", btn);
      icon.classList.toggle("bi-heart");
      icon.classList.toggle("bi-heart-fill");
    });
  });
}

function syncFormFromURL(){
  const params = new URLSearchParams(location.search);
  qsa("#filtersForm [name]").forEach(el => {
    const name = el.name;
    if (el.type === "checkbox"){
      el.checked = params.get(name) === "on";
    } else {
      if (params.has(name)) el.value = params.get(name);
    }
  });
  return params;
}

function syncURLFromForm(){
  const formData = new FormData($form);
  const params = new URLSearchParams();
  for (const [k,v] of formData.entries()){
    if (v && v !== "") params.set(k, v);
  }
  // checkboxes no marcados no van
  qsa('#filtersForm input[type="checkbox"]').forEach(cb=>{
    if (cb.checked) params.set(cb.name, "on");
  });
  history.replaceState(null, "", "?" + params.toString());
  return params;
}

function update(){
  const params = syncURLFromForm();
  const filtered = applyFilters(PROPIEDADES, params);
  renderCards(filtered);
}

function init(){
  // Cargar estado desde URL
  const params = syncFormFromURL();
  renderCards(applyFilters(PROPIEDADES, params));

  // Búsqueda instantánea
  const $q = qs("#q");
  let t;
  $q.addEventListener("input", ()=>{
    clearTimeout(t);
    t = setTimeout(update, 250);
  });

  // Submit/Change
  $form.addEventListener("submit", (e)=>{ e.preventDefault(); update(); });
  $form.addEventListener("change", update);

  // Limpiar
  qs("#clearFilters").addEventListener("click", ()=>{
    $form.reset();
    qsa('#filtersForm input[type="checkbox"]').forEach(cb=>cb.checked=false);
    history.replaceState(null, "", location.pathname);
    renderCards(PROPIEDADES);
    $count.textContent = `Mostrando ${PROPIEDADES.length} propiedades`;
  });

  // Toggle vista
  $toggle.addEventListener("click", ()=>{
    const isList = $grid.getAttribute("data-view") === "list";
    $grid.setAttribute("data-view", isList ? "grid" : "list");
    $toggle.setAttribute("aria-pressed", String(!isList));
    $toggle.innerHTML = isList
      ? '<i class="bi bi-grid-3x3-gap me-1"></i> Vista cuadrícula'
      : '<i class="bi bi-view-stacked me-1"></i> Vista lista';
  });
}

document.addEventListener("DOMContentLoaded", init);
