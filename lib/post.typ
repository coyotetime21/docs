#import "theme.typ": theme, u
#import "components.typ": *
#import "slides.typ": slide, asset, present, pad2

#let post-page(body) = {
  set page(width: 810pt, height: 810pt, margin: u(7))
  set text(
    lang: "ru",
    font: theme.fonts.body.family,
    weight: theme.fonts.body.weight,
    size: theme.size.body,
    fill: theme.normal.text,
    hyphenate: false,
  )
  body
}

#let labeled-rows(rows, label-col: u(14)) = grid(
  columns: (label-col, 1fr), column-gutter: u(2), row-gutter: u(3), align: left + top,
  ..rows.map(((l, body)) => (pad(top: u(0.5), l), body)).flatten(),
)

#let logo(path, size: u(4), fill: theme.normal.text) = {
  let svg = read(path).replace("<svg ", "<svg fill=\"" + fill.to-hex() + "\" ")
  image(bytes(svg), format: "svg", height: size)
}

#let phone(path, height: 100%, pal: theme.normal) = {
  let bezel = u(1.25)
  let r = theme.shape.radius * 3
  with-shadow(pal: pal, radius: r, offset: u(1.5), block(
    height: height, inset: bezel, radius: r, fill: pal.surface,
    stroke: theme.shape.stroke + pal.border,
    block(height: 100%, radius: r - bezel, clip: true, image(path, height: 100%)),
  ))
}

#let post-intro(c) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "display")
  v(1fr)
  labeled-rows((
    (label(c.company_label), para(c.company, fill: theme.normal.muted)),
    (label(c.pain_label, fill: theme.normal.accent), para(c.pain)),
  ))
  v(1fr)
  line(length: 100%, stroke: theme.shape.stroke + theme.normal.border)
  v(u(3))
  grid(columns: (auto, 1fr), column-gutter: u(3), align: horizon,
    num(c.metric, size: theme.size.metric),
    para(c.metric_caption, fill: theme.normal.muted),
  )
  v(u(1))
})

#let post-solution(
  c,
  step-gap: u(2),
) = slide({
  eyebrow(c.label)
  v(u(3))
  title(c.title, size: "h2")
  v(u(2.5))
  para(c.text, fill: theme.normal.muted)
  v(1fr)

  label(c.stack_label)
  v(u(2))
  c.stack.map(s => box(stack(dir: ltr, spacing: u(1.25),
    align(horizon, logo(asset(s.logo), size: u(5))),
    align(horizon, para(s.name, weight: 500)),
  ))).join(h(1fr))
  v(1fr)

  label(c.flow_label)
  v(u(2.5))
  let n = c.flow.len()
  let dot = u(5)
  grid(columns: (dot, 1fr), column-gutter: u(2.5), align: horizon,
    ..c.flow.enumerate().map(((i, s)) => {
      let last = i == n - 1
      let mark = circle(radius: dot / 2,
        fill: if last { theme.normal.accent } else { theme.normal.bg },
        stroke: theme.shape.stroke * 1.5 + if last { theme.normal.accent } else { theme.normal.border },
        align(center + horizon, num(str(i + 1), size: theme.size.small,
          fill: if last { theme.normal.on-accent } else { theme.normal.accent })))
      let joint = line(angle: 90deg, length: step-gap, stroke: theme.shape.stroke * 1.5 + theme.normal.border)
      (
        mark,
        para(s, size: theme.size.lead, weight: if last { 500 } else { auto },
          fill: if last { theme.normal.accent } else { theme.normal.text }),
        ..if not last { (align(center, joint), []) },
      )
    }).flatten(),
  )
  v(u(1))
})

#let post-chat(c) = slide({
  grid(columns: (1fr, auto), column-gutter: u(3), align: bottom,
    eyebrow(c.label),
    align(right, stack(spacing: u(2.5),
      align(right, num(c.metric, size: theme.size.h2)),
      align(right, label(c.metric_caption)),
    )),
  )
  v(u(4))
  block(width: 100%, height: 1fr, align(center, phone(asset(c.screenshot), height: 100%)))
})
