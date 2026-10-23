// slides.typ — слайды. Каждый слайд принимает свой блок из content.yaml (`c`)
// и параметры раскладки. Параметры с комментарием TWEAK можно смело менять
// прямо в вызове из creds/main.typ, например: #cover(c.cover, columns: (2fr, 1fr)).

#import "theme.typ": theme, u
#import "components.typ": *

// Пустое значение в YAML: null, "none" или "".
#let present(x) = x != none and x != "none" and x != ""

// Путь из content.yaml → путь от корня проекта; none/"none"/"" → none.
#let asset(p) = {
  if not present(p) { none }
  else if p.starts-with("/") { p } else { "/" + p }
}

#let pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

// Каркас слайда: фон, узор, нижний колонтитул с именем и номером.
#let slide(pal: theme.normal, footer: true, body) = {
  // Все вертикальные отступы задаются явно через v(u(n)), без автоматических.
  set par(spacing: 0pt)
  set block(spacing: 0pt)
  page(
  fill: pal.bg,
  background: background(pal),
  footer: if footer {
    set text(size: theme.size.label)
    grid(columns: (1fr, auto),
      label(theme.brand.name + " · " + theme.brand.role, pal: pal),
      context label(pad2(counter(page).get().first()) + " / " + pad2(counter(page).final().first()), pal: pal),
    )
  },
  body,
)}

// Маркер-точка перед фразой.
#let marker(pal) = box(circle(radius: 5pt, fill: pal.accent), baseline: -0.2em)

// ============================================================
// 1. Обложка
// ============================================================
#let cover(
  c,
  // TWEAK: ширина колонок «текст : фото». Больше первое число — шире текст, уже фото.
  columns: (1.6fr, 1fr),
  // TWEAK: расстояние между колонкой текста и фото.
  gap: u(8),
  // TWEAK: вертикальное выравнивание текста: top | horizon | bottom.
  text-align: horizon,
  // TWEAK: высота фото (100% = вся высота слайда без полей).
  photo-height: 100%,
) = {
  let pal = if theme.comp.cover-inverse { theme.inverse } else { theme.normal }
  slide(pal: pal, footer: false, grid(
    columns: columns, column-gutter: gap, rows: 100%,
    align(text-align, stack(
      eyebrow(theme.brand.name + " · " + theme.brand.role, pal: pal),
      v(u(4)),
      title(theme.brand.offer, size: "display", pal: pal),
      v(u(5)),
      block(width: 92%, lead(theme.brand.offer-sub, pal: pal)),
      v(u(5)),
      tags(c.at("tags", default: ()), pal: pal),
    )),
    align(horizon, photo(asset(c.at("photo", default: none)), height: photo-height, pal: pal)),
  ))
}

// ============================================================
// 2. С чем работаю
// ============================================================
#let services(
  c,
  // TWEAK: расстояние между карточками.
  gap: u(3),
  // TWEAK: внутренний отступ карточек.
  inset: u(3),
  // TWEAK: высота карточек.
  card-height: u(32),
  // TWEAK: отступ между заголовком карточки и её текстом.
  title-gap: u(4),
  // TWEAK: отступ между шапкой (label/h2/lead) и карточками. 1fr — карточки
  // встают посередине между шапкой и нижней фразой; u(6) — прижаты к шапке.
  head-gap: 1fr,
) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "h2")
  v(u(3))
  lead(c.lead)
  v(head-gap)
  grid(
    columns: (1fr,) * c.cards.len(), column-gutter: gap,
    ..c.cards.map(k => card(height: card-height, inset: inset, stack(
      title(k.title, size: "h3"),
      v(title-gap),
      para(k.text),
      v(1fr),
      tags(k.at("tags", default: ())),
    ))),
  )
  v(1fr)
  grid(columns: (auto, 1fr), column-gutter: u(2), align: horizon,
    marker(theme.normal), para(c.note, weight: 500))
})

// ============================================================
// 3. Подход
// ============================================================
#let approach(
  c,
  // TWEAK: колонки «заголовок : пункты».
  columns: (1fr, 1.25fr),
  // TWEAK: расстояние между колонками.
  gap: u(8),
  // TWEAK: расстояние между пунктами справа.
  point-gap: u(5),
) = slide({
  let stats = c.at("stats", default: none)
  let has-stats = stats != none and stats.len() > 0
  grid(
    columns: columns, column-gutter: gap, rows: if has-stats { auto } else { 100% },
    align(horizon, stack(
      eyebrow(c.label),
      v(u(2)),
      title(c.title, size: "h1"),
      v(u(4)),
      lead(c.lead),
    )),
    align(horizon, stack(spacing: point-gap, ..c.points.enumerate().map(((i, p)) => grid(
      columns: (u(7), 1fr), column-gutter: u(2), align: top,
      num(pad2(i + 1), size: theme.size.h3),
      stack(title(p.title, size: "h3"), v(u(2)), para(p.text, fill: theme.normal.muted)),
    )))),
  )
  if has-stats {
    v(1fr)
    line(length: 100%, stroke: theme.shape.stroke + theme.normal.border)
    v(u(3))
    grid(columns: (1fr,) * stats.len(), column-gutter: u(4),
      ..stats.map(s => stack(spacing: u(1),
        num(s.value, size: theme.size.h1),
        para(s.caption, fill: theme.normal.muted))))
  }
})

// ============================================================
// 4…N. Кейс (один кейс на слайд)
// ============================================================
#let case(
  c,
  // Номер кейса для надзаголовка «Ниша · Кейс #n». main.typ передаёт его сам.
  n: 1,
  // TWEAK: true — текст слева, скриншот справа. main.typ чередует сам.
  flip: false,
  // TWEAK: колонки «скриншот : текст». Больше первое число — крупнее скриншот.
  columns: (1fr, 1.3fr),
  // TWEAK: расстояние между скриншотом и текстом.
  gap: u(6),
  // TWEAK: высота скриншота (100% — вся высота слайда без полей, auto — по пропорциям картинки).
  shot-height: 100%,
  // TWEAK: ширина колонки с подписями «Было/Стало».
  label-col: u(12),
  // TWEAK: вертикальное выравнивание текстовой колонки: top | horizon | bottom.
  text-align: horizon,
) = slide({
  let quote = c.at("quote", default: none)
  let shot = align(horizon, shot-frame(asset(c.at("screenshot", default: none)),
    hint: c.at("screenshot_hint", default: none), height: shot-height))
  let body = align(text-align, stack(
      eyebrow(c.niche + " · Кейс #" + str(n)),
      v(u(2.5)),
      title(c.title, size: "h2"),
      v(u(3.5)),
      grid(columns: (label-col, 1fr), column-gutter: u(2), row-gutter: u(3), align: left + top,
        // u(0.5): подпись встаёт на одну линию с первой строкой текста.
        pad(top: u(0.5), label("Было")), para(c.before, fill: theme.normal.muted),
        pad(top: u(0.5), label("Стало", fill: theme.normal.accent)), para(c.after),
      ),
      v(u(3.5)),
      line(length: 100%, stroke: theme.shape.stroke + theme.normal.border),
      v(u(3)),
      metric(c.metric, c.metric_caption),
      if present(quote) {
        v(u(2.5))
        para("«" + quote + "»", size: theme.size.small, fill: theme.normal.muted)
        let who = c.at("quote_author", default: none)
        if present(who) { v(u(1)); label(who) }
      },
    ))
  grid(
    columns: if flip { columns.rev() } else { columns }, column-gutter: gap, rows: 100%,
    ..if flip { (body, shot) } else { (shot, body) },
  )
})

// ============================================================
// Отзывы (только если их 2 и больше)
// ============================================================
#let testimonials(
  c,
  items,
  // TWEAK: сколько отзывов в ряд.
  cols: 2,
  // TWEAK: расстояние между карточками.
  gap: u(4),
) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "h2")
  v(u(5))
  grid(columns: (1fr,) * cols, column-gutter: gap, row-gutter: gap,
    ..items.map(t => card(stack(
      para("«" + t.text + "»"),
      v(u(2)),
      label(t.author),
    ))))
})

// ============================================================
// Как работаем
// ============================================================
#let process(
  c,
  // TWEAK: расстояние между карточками шагов.
  gap: u(3),
  // TWEAK: высота карточек шагов.
  card-height: u(38),
  // TWEAK: внутренний отступ карточек.
  inset: u(3),
  // TWEAK: отступ между названием шага и описанием.
  title-gap: u(4),
) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "h2")
  v(1fr)
  grid(
    columns: (1fr,) * c.steps.len(), column-gutter: gap,
    ..c.steps.enumerate().map(((i, s)) => card(height: card-height, inset: inset, stack(
      num(pad2(i + 1), size: theme.size.h2),
      v(u(2)),
      title(s.title, size: "h3"),
      v(title-gap),
      para(s.text, fill: theme.normal.muted),
      v(1fr),
      tags((s.term,)),
    ))),
  )
  v(1fr)
})

// ============================================================
// FAQ
// ============================================================
#let faq(
  c,
  // TWEAK: число колонок сетки вопросов (3 колонки × 2 ряда = 6 вопросов).
  cols: 3,
  // TWEAK: расстояние между колонками.
  col-gap: u(5),
  // TWEAK: расстояние между рядами.
  row-gap: u(5),
) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "h2")
  v(1fr)
  grid(
    columns: (1fr,) * cols, column-gutter: col-gap, row-gutter: row-gap,
    ..c.items.map(q => stack(
      para(q.q, weight: 600),
      v(u(1.5)),
      para(q.a, fill: theme.normal.muted),
    )),
  )
  v(1fr)
})

// ============================================================
// Финал
// ============================================================
#let cta(
  c,
  url,
  // TWEAK: колонки «текст : QR».
  columns: (1fr, auto),
  // TWEAK: расстояние между текстом и QR.
  gap: u(10),
  // TWEAK: размер QR-кода.
  qr-size: u(30),
) = {
  let pal = if theme.comp.cta-inverse { theme.inverse } else { theme.normal }
  slide(pal: pal, footer: false, grid(
    columns: columns, column-gutter: gap, rows: 100%,
    align(horizon, stack(
      eyebrow(c.label, pal: pal),
      v(u(3)),
      title(c.title, size: "display", pal: pal),
      v(u(5)),
      block(width: 90%, lead(c.lead, pal: pal)),
      v(u(6)),
      grid(columns: (auto, auto), column-gutter: u(4), align: horizon,
        button(c.button, url, pal: pal),
        para(theme.brand.telegram, size: theme.size.lead, pal: pal, weight: 500),
      ),
    )),
    align(horizon + center, stack(spacing: u(2),
      qr(url, size: qr-size, pal: pal),
      label(c.qr_caption, pal: pal),
    )),
  ))
}
