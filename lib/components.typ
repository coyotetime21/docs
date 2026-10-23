// components.typ — мелкие блоки вёрстки. Вариант каждого блока выбирается
// только в /style.yaml (components.*), здесь лишь их реализация.
// Почти все функции принимают `pal` — палитру слайда (theme.normal или theme.inverse).

#import "theme.typ": theme, u
#import "@preview/tiaoma:0.3.0"

#let nbsp = "\u{a0}"
#let wj = "\u{2060}" // word joiner: запрещает перенос строки в этом месте
#let placeholder-re = regex("\[ЗАПОЛНИТЬ[^\]]*\]")

// ---------- Типографика ----------

// Неразрывные пробелы: перед тире, внутри чисел («182 400 ₽»), между числом
// и словом («7–14 дней»), после коротких предлогов и союзов.
// tie-end: склеить два последних слова, чтобы в заголовке не повисло одно слово.
#let typo(s, tie-end: false) = {
  if type(s) != str { return s }
  s = s.replace(regex(" +([—–])"), m => nbsp + m.captures.at(0))
  // «7–14», «2–4»: диапазон не разрывается на две строки.
  s = s.replace(regex("(\d)–(\d)"), m => m.captures.at(0) + wj + "–" + wj + m.captures.at(1))
  // «ИИ-агентов»: не переносить по дефису.
  s = s.replace(regex("(\w)-(\w)"), m => m.captures.at(0) + "-" + wj + m.captures.at(1))
  s = s.replace(regex("(\d) (\d{3})"), m => m.captures.at(0) + nbsp + m.captures.at(1))
  s = s.replace(regex("(\d) (\S)"), m => m.captures.at(0) + nbsp + m.captures.at(1))
  s = s.replace(regex("(^|[\s(«])([а-яёА-ЯЁ]{1,2}) "), m => m.captures.at(0) + m.captures.at(1) + nbsp)
  if tie-end {
    s = s.replace(regex(" (\S+)$"), m => nbsp + m.captures.at(0))
  }
  s
}

// Строка из YAML → content. Заглушки [ЗАПОЛНИТЬ: …] подсвечиваются вторым
// акцентом, чтобы их было видно на любом слайде.
#let rich(s, pal: theme.normal, tie-end: false) = {
  if s == none { return none }
  if type(s) != str { return s }
  let s = typo(s, tie-end: tie-end)
  let out = ()
  let last = 0
  for m in s.matches(placeholder-re) {
    out.push(s.slice(last, m.start))
    out.push(text(fill: pal.accent-2, s.slice(m.start, m.end)))
    last = m.end
  }
  out.push(s.slice(last))
  out.join()
}

#let with-font(f, body) = {
  set text(font: f.family, weight: f.weight, tracking: f.tracking)
  if f.upper { upper(body) } else { body }
}

// ---------- Текстовые стили ----------

// Обычный текст абзаца.
#let para(s, size: theme.size.body, fill: none, pal: theme.normal, weight: auto) = {
  set text(size: size, fill: if fill == none { pal.text } else { fill })
  set text(weight: weight) if weight != auto
  set par(leading: (theme.fonts.body.leading - 1) * 1em + 0.25em, justify: false)
  rich(s, pal: pal)
}

#let lead(s, pal: theme.normal) = para(s, size: theme.size.lead, fill: pal.muted, pal: pal)

// Надзаголовок (label).
#let label(s, pal: theme.normal, fill: none) = {
  set text(size: theme.size.label, fill: if fill == none { pal.muted } else { fill })
  set par(leading: 0.5em)
  with-font(theme.label-font, rich(s, pal: pal))
}

// Надзаголовок слайда (верхний мини-заголовок над h1/h2) — акцентом.
#let eyebrow(s, pal: theme.normal) = label(s, pal: pal, fill: pal.accent)

// Декорация заголовка: none | line | dot | slash.
#let heading-deco(pal) = {
  let d = theme.comp.heading-deco
  if d == "dot" { box(circle(radius: 0.14em, fill: pal.accent), baseline: -0.32em) + h(0.35em) }
  else if d == "slash" { text(fill: pal.accent, "/") + h(0.25em) }
  else { none }
}

// Заголовок любого уровня: size — один из ключей type_scale (h3, h2, h1, display).
#let title(s, size: "h2", pal: theme.normal, deco: true) = {
  let f = theme.fonts.heading
  set text(size: theme.size.at(size), fill: pal.text, hyphenate: false)
  set par(leading: (f.leading - 1) * 1em + 0.2em, justify: false)
  let body = with-font(f, rich(s, pal: pal, tie-end: true))
  if deco and theme.comp.heading-deco == "line" and size != "h3" {
    stack(spacing: u(2), rect(width: u(6), height: 3pt, fill: pal.accent), body)
  } else if deco and size != "h3" {
    heading-deco(pal) + body
  } else { body }
}

// Цифры: номера шагов, метрики.
#let num(s, size: theme.size.h3, fill: none, pal: theme.normal) = {
  set text(size: size, fill: if fill == none { pal.accent } else { fill })
  set par(leading: 0.3em)
  with-font(theme.fonts.numbers, rich(s, pal: pal))
}

// Крупная метрика с подписью. Длинная метрика уменьшается, чтобы встать в одну строку.
#let metric(value, caption, pal: theme.normal) = stack(
  spacing: u(3),
  layout(size => {
    let full = theme.size.metric
    let w = measure(box(num(value, size: full, pal: pal))).width
    let fit = if w > size.width { full * (size.width / w) * 0.98 } else { full }
    num(value, size: fit, pal: pal)
  }),
  para(caption, size: theme.size.body, fill: pal.muted, pal: pal),
)

// ---------- Теги ----------

#let tag(s, pal: theme.normal) = {
  let kind = theme.comp.tag
  let body = label(s, pal: pal, fill: if kind == "filled" { pal.text } else { pal.muted })
  if kind == "pill" {
    box(inset: (x: u(1.5), y: u(0.75)), radius: 999pt, stroke: theme.shape.stroke + pal.border, body)
  } else if kind == "filled" {
    box(inset: (x: u(1.5), y: u(0.75)), radius: theme.shape.radius / 2, fill: pal.surface, body)
  } else { box(body) }
}

// Ряд тегов. В варианте caps теги разделяются точкой.
#let tags(items, pal: theme.normal) = {
  if items == none or items.len() == 0 { return none }
  if theme.comp.tag == "caps" {
    items.map(t => tag(t, pal: pal)).join(box(label(nbsp + "·" + nbsp, pal: pal)) + " ")
  } else {
    items.map(t => tag(t, pal: pal)).join(h(u(1)) + " ")
  }
}

// ---------- Карточка: outline | filled | shadow | bar | plain ----------

// Тень: смещённый полупрозрачный прямоугольник под блоком.
#let with-shadow(body, radius: theme.shape.radius, pal: theme.normal, offset: u(1)) = {
  let shadow = color.mix((black, 70%), (pal.bg, 30%)).transparentize(35%)
  box(layout(size => {
    let m = measure(width: size.width, body)
    place(top + left, dx: offset, dy: offset,
      rect(width: m.width, height: m.height, radius: radius, fill: shadow))
    body
  }))
}

#let card(body, pal: theme.normal, height: auto, inset: u(3)) = {
  let kind = theme.comp.card
  let r = theme.shape.radius
  let s = theme.shape.stroke
  if kind == "outline" {
    block(width: 100%, height: height, inset: inset, radius: r, stroke: s + pal.border, body)
  } else if kind == "filled" {
    block(width: 100%, height: height, inset: inset, radius: r, fill: pal.surface, body)
  } else if kind == "shadow" {
    with-shadow(pal: pal, block(width: 100%, height: height, inset: inset, radius: r, fill: pal.surface, body))
  } else if kind == "bar" {
    // Вертикальная полоса слева, без рамки.
    block(width: 100%, height: height, inset: (left: inset, rest: u(0.5)),
      stroke: (left: 3pt + color.mix((pal.muted, 55%), (pal.bg, 45%))), body)
  } else {
    block(width: 100%, height: height, body)
  }
}

// ---------- Кнопка: filled | outline | underline ----------

#let button(s, url, pal: theme.normal) = {
  let kind = theme.comp.button
  let t(fill) = {
    set text(size: theme.size.lead, fill: fill, weight: 500)
    rich(s, pal: pal)
  }
  let body = if kind == "filled" {
    box(inset: (x: u(4), y: u(2.25)), radius: theme.shape.radius, fill: pal.accent, t(pal.on-accent))
  } else if kind == "outline" {
    box(inset: (x: u(4), y: u(2.25)), radius: theme.shape.radius,
      stroke: 2 * theme.shape.stroke + pal.accent, t(pal.accent))
  } else {
    underline(stroke: 2pt + pal.accent, offset: 6pt, t(pal.accent))
  }
  link(url, body)
}

// ---------- Фон слайда: none | grid | dots ----------

#let background(pal) = {
  let kind = theme.comp.pattern
  let c = pal.border.transparentize(45%)
  let step = u(4)
  if kind == "grid" {
    rect(width: 100%, height: 100%, fill: tiling(size: (step, step),
      place(top + left, line(length: step, stroke: 0.6pt + c)) +
      place(top + left, line(length: step, angle: 90deg, stroke: 0.6pt + c))))
  } else if kind == "dots" {
    rect(width: 100%, height: 100%, fill: tiling(size: (step, step),
      place(top + left, dx: step / 2 - 1.25pt, dy: step / 2 - 1.25pt, circle(radius: 1.25pt, fill: c))))
  } else { none }
}

// ---------- Рамка скриншота: border | shadow | window ----------

// path: путь к картинке ("/creds/assets/cases/x.png") или none → аккуратная заглушка.
// height: auto — высота по пропорциям картинки, без обрезки.
#let shot-frame(path, hint: none, height: 100%, pal: theme.normal) = {
  let kind = theme.comp.frame
  let r = theme.shape.radius
  let s = theme.shape.stroke
  let bar-h = if kind == "window" { u(4) } else { 0pt }

  let inner = if path == none {
    // Заглушка: поверхность, пунктирная рамка внутри и подпись по центру.
    block(width: 100%, height: 100%, fill: pal.surface, inset: u(2), block(
      width: 100%, height: 100%, radius: theme.shape.radius / 2,
      stroke: (paint: pal.border, thickness: 2 * s, dash: "dashed"),
      align(center + horizon, box(width: 75%, para(
        if hint == none { "Скриншот: что показать" } else { hint },
        size: theme.size.body, fill: pal.muted, pal: pal)))))
  } else if height == auto {
    image(path, width: 100%)
  } else {
    image(path, width: 100%, height: 100%, fit: "cover")
  }

  let window-bar = block(width: 100%, height: bar-h, fill: color.mix((pal.surface, 60%), (pal.border, 40%)),
    inset: (x: u(2)), align(horizon, stack(dir: ltr, spacing: u(1),
      ..range(3).map(_ => circle(radius: 4pt, fill: pal.border)))))

  let frame = block(width: 100%, height: height, radius: r, clip: true,
    stroke: if kind != "shadow" { s + pal.border } else { none },
    stack(if kind == "window" { window-bar }, block(width: 100%, height: if height == auto { auto } else { 100% - bar-h }, inner)))

  if kind == "shadow" { with-shadow(frame, pal: pal, offset: u(1.5)) } else { frame }
}

// ---------- Фото ----------

// path: путь к фото или none → градиент из accent и surface с подписью.
#let photo(path, width: 100%, height: 100%, pal: theme.normal) = {
  let r = theme.shape.radius
  if path == none {
    block(width: width, height: height, radius: r, clip: true,
      fill: gradient.linear(pal.accent, pal.surface, angle: 50deg),
      align(center + horizon, label("фото", pal: pal, fill: pal.text)))
  } else {
    block(width: width, height: height, radius: r, clip: true,
      image(path, width: 100%, height: 100%, fit: "cover"))
  }
}

// ---------- QR ----------

#let qr(url, size: u(25), pal: theme.normal) = link(url, block(
  inset: u(2), radius: theme.shape.radius, fill: white,
  tiaoma.qrcode(url, width: size, options: (fg-color: black, bg-color: white)),
))
