-- VIP Cocktail Catering Bar - schema Supabase
-- Rulează tot acest fișier o singură dată, în Supabase: proiectul tău > SQL Editor > New query > paste > Run.

-- 1. Tabela cu tot conținutul editabil, un singur rând, o coloană JSONB.
create table if not exists site_content (
  id text primary key default 'main',
  data jsonb not null,
  updated_at timestamptz not null default now()
);

alter table site_content enable row level security;

-- citire publică (site-ul public are nevoie de date fără login)
create policy "citire publica" on site_content
  for select using (true);

-- scriere doar pentru utilizatori autentificați (adică doar clienta, din admin.html)
create policy "scriere doar autentificat" on site_content
  for update using (auth.role() = 'authenticated');

create policy "insert doar autentificat" on site_content
  for insert with check (auth.role() = 'authenticated');

-- 2. Rândul inițial, cu datele curente din index.html (le poți edita direct în cabinet după).
insert into site_content (id, data) values ('main', '{
  "offers": [
    {"n":1,"qty":100,"price":9000,"items":{"Mojito":25,"Limonade exotice":25,"Blue Lagoon":21,"Pornstar Martini":29}},
    {"n":2,"qty":140,"price":12000,"items":{"Mojito":25,"Pornstar Martini":15,"Cosmopolitan":10,"Aperol Spritz":15,"Blue Lagoon":15,"Limonade exotice":15,"Cuba Libre":15,"Green Mexican":15,"B-52":15}},
    {"n":3,"qty":180,"price":15000,"items":{"Mojito":30,"Pornstar Martini":15,"Cosmopolitan":15,"Aperol Spritz":20,"Blue Lagoon":15,"Limonade exotice":25,"Cuba Libre":20,"Green Mexican":20,"B-52":20}},
    {"n":4,"qty":210,"price":17000,"items":{"Mojito":25,"Pornstar Martini":20,"Cosmopolitan":20,"Aperol Spritz":25,"Blue Lagoon":20,"Limonade exotice":20,"Cuba Libre":20,"Green Mexican":30,"B-52":30}},
    {"n":5,"qty":250,"price":20000,"items":{"Mojito":35,"Pornstar Martini":30,"Cosmopolitan":20,"Aperol Spritz":25,"Blue Lagoon":20,"Limonade exotice":35,"Cuba Libre":15,"Green Mexican":35,"B-52":35}},
    {"n":6,"qty":300,"price":24000,"items":{"Mojito":40,"Pornstar Martini":30,"Cosmopolitan":30,"Aperol Spritz":30,"Blue Lagoon":30,"Limonade exotice":40,"Cuba Libre":30,"Green Mexican":35,"B-52":35}},
    {"n":7,"qty":350,"price":28000,"items":{"Mojito":60,"Pornstar Martini":30,"Cosmopolitan":30,"Aperol Spritz":30,"Blue Lagoon":30,"Limonade exotice":50,"Cuba Libre":30,"Green Mexican":45,"B-52":45}},
    {"n":8,"qty":400,"price":32000,"items":{"Mojito":65,"Pornstar Martini":35,"Cosmopolitan":35,"Aperol Spritz":35,"Blue Lagoon":30,"Limonade exotice":60,"Cuba Libre":30,"Green Mexican":55,"B-52":55}}
  ],
  "torta": {
    "unitPrice": 70,
    "tiers": [
      {"qty":100,"price":7000,"label":"Minimul de pornire"},
      {"qty":171,"price":12000,"label":"Pentru evenimente medii"},
      {"qty":200,"price":14000,"label":"Pentru evenimente mari"}
    ],
    "flavors": 4
  },
  "pricing": {
    "perUnit": 80,
    "rezervaUnitar": 85,
    "avans": 2000,
    "kmFee": 10
  },
  "gallery": [
    {"file":"gal-01","caption":"Cocktailuri servite, grădină"},
    {"file":"gal-02","caption":"Bar montat, perete de piatră"},
    {"file":"gal-03","caption":"Bar montat, seara"},
    {"file":"gal-04","caption":"Etajeră cu citrice, la eveniment"},
    {"file":"gal-05","caption":"Bar în aer liber, la nuntă"},
    {"file":"gal-06","caption":"Shoturi cu citrice uscate"},
    {"file":"gal-07","caption":"Cocktail cu fum, decor de fructe"},
    {"file":"gal-08","caption":"Cocktailuri cu fructe de pădure"},
    {"file":"gal-09","caption":"Cupe cu portocală și căpșuni"}
  ]
}') on conflict (id) do nothing;

-- 3. Bucket de Storage pentru poze (galerie, torta etc - upload din admin.html).
insert into storage.buckets (id, name, public)
values ('site-images', 'site-images', true)
on conflict (id) do nothing;

create policy "citire publica poze" on storage.objects
  for select using (bucket_id = 'site-images');

create policy "upload doar autentificat" on storage.objects
  for insert with check (bucket_id = 'site-images' and auth.role() = 'authenticated');

create policy "sterge doar autentificat" on storage.objects
  for delete using (bucket_id = 'site-images' and auth.role() = 'authenticated');

create policy "update doar autentificat" on storage.objects
  for update using (bucket_id = 'site-images' and auth.role() = 'authenticated');
