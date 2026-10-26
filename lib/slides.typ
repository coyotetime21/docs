#import "theme.typ": theme, u
#import "components.typ": *

#let present(x) = x != none and x != "none" and x != ""

#let asset(p) = {
  if not present(p) { none }
  else if p.starts-with("/") { p } else { "/" + p }
}

#let pad2(n) = if n < 10 { "0" + str(n) } else { str(n) }

#let slide(pal: theme.normal, footer: true, body) = {
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

#let marker(pal) = box(circle(radius: 5pt, fill: pal.accent), baseline: -0.2em)

#let cover(
  c,
  columns: (1.6fr, 1fr),
  gap: u(8),
  text-align: horizon,
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

#let services(
  c,
  gap: u(3),
  inset: u(3),
  card-height: u(32),
  title-gap: u(4),
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

#let approach(
  c,
  columns: (1fr, 1.25fr),
  gap: u(8),
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

#let case(
  c,
  n: 1,
  flip: false,
  columns: (1fr, 1.3fr),
  gap: u(6),
  shot-height: 100%,
  label-col: u(12),
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

#let testimonials(
  c,
  items,
  cols: 2,
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

#let process(
  c,
  gap: u(3),
  card-height: u(38),
  inset: u(3),
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

#let faq(
  c,
  cols: 3,
  col-gap: u(5),
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

#let cta(
  c,
  url,
  columns: (1fr, auto),
  gap: u(10),
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
