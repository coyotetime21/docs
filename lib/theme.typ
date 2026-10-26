#let style = yaml("/style.yaml")

#let get(dict, path, default) = {
  let cur = dict
  for key in path.split(".") {
    if type(cur) != dictionary or key not in cur or cur.at(key) == none { return default }
    cur = cur.at(key)
  }
  cur
}

#let unit = get(style, "shape.spacing_unit", 8)
#let u(n) = n * unit * 1pt

#let color-defaults = (
  bg: "#141619", surface: "#1D2024", text: "#EDEAE3", muted: "#9DA1A8",
  border: "#30343A", accent: "#F0A93A", on_accent: "#141619",
  accent_2: "#7FB7FF", inverse_bg: "#F0A93A", inverse_text: "#141619",
)
#let colors = {
  let out = (:)
  for (key, hex) in color-defaults { out.insert(key, rgb(get(style, "colors." + key, hex))) }
  out
}

#let luminance(c) = {
  let ch = rgb(c).components(alpha: false).map(v => {
    let x = v / 100%
    if x <= 0.03928 { x / 12.92 } else { calc.pow((x + 0.055) / 1.055, 2.4) }
  })
  0.2126 * ch.at(0) + 0.7152 * ch.at(1) + 0.0722 * ch.at(2)
}
#let contrast(a, b) = {
  let (la, lb) = (luminance(a), luminance(b))
  (calc.max(la, lb) + 0.05) / (calc.min(la, lb) + 0.05)
}

#let pal-normal = (
  bg: colors.bg, surface: colors.surface, text: colors.text, muted: colors.muted,
  border: colors.border, accent: colors.accent, on-accent: colors.on_accent,
  accent-2: colors.accent_2,
)

#let pal-inverse = {
  let (bg, fg) = (colors.inverse_bg, colors.inverse_text)
  let accent-ok = contrast(colors.accent, bg) >= 3
  let accent = if accent-ok { colors.accent } else { fg }
  (
    bg: bg,
    surface: color.mix((fg, 8%), (bg, 92%)),
    text: fg,
    muted: color.mix((fg, 72%), (bg, 28%)),
    border: color.mix((fg, 25%), (bg, 75%)),
    accent: accent,
    on-accent: if accent-ok { colors.on_accent } else { bg },
    accent-2: fg,
  )
}

#let generic-fallback = (serif: "Libertinus Serif", monospace: "DejaVu Sans Mono")

#let font-role(role, defaults) = {
  let f = get(style, "fonts." + role, (:))
  let family = get(f, "family", defaults.family)
  let fb = generic-fallback.at(get(f, "fallback", ""), default: none)
  (
    family: if fb == none { (family,) } else { (family, fb) },
    weight: get(f, "weight", defaults.weight),
    tracking: get(f, "letter_spacing_em", 0) * 1em,
    upper: get(f, "case", "none") == "upper",
    leading: get(f, "line_height", defaults.line_height),
  )
}

#let fonts = (
  heading: font-role("heading", (family: "Source Serif 4", weight: 600, line_height: 1.1)),
  body: font-role("body", (family: "Rubik", weight: 400, line_height: 1.45)),
  numbers: font-role("numbers", (family: "JetBrains Mono", weight: 600, line_height: 1.1)),
)

#let label-font = {
  let base = fonts.at(get(style, "fonts.label.font", "body"), default: fonts.body)
  base + (
    weight: get(style, "fonts.label.weight", base.weight),
    tracking: get(style, "fonts.label.letter_spacing_em", 0.08) * 1em,
    upper: get(style, "fonts.label.case", "upper") == "upper",
  )
}

#let size-defaults = (
  label: 16, small: 17, body: 22, lead: 25, h3: 29, h2: 39, h1: 52, display: 69, metric: 79,
)
#let size = {
  let out = (:)
  for (key, v) in size-defaults { out.insert(key, get(style, "type_scale.sizes." + key, v) * 1pt) }
  out
}

#let pad = get(style, "shape.slide_padding", (64, 72))

#let shape = (
  radius: get(style, "shape.radius", 12) * 1pt,
  stroke: get(style, "shape.border_width", 1) * 1pt,
  pad-y: pad.at(0) * 1pt,
  pad-x: pad.at(1) * 1pt,
)

#let variant(key, allowed, default) = {
  let v = get(style, "components." + key, default)
  if v in allowed { v } else { default }
}

#let comp = (
  card: variant("card", ("outline", "filled", "shadow", "bar", "plain"), "outline"),
  tag: variant("tag", ("pill", "filled", "caps"), "pill"),
  button: variant("button", ("filled", "outline", "underline"), "filled"),
  heading-deco: variant("heading_decoration", ("none", "line", "dot", "slash"), "none"),
  pattern: variant("background_pattern", ("none", "grid", "dots"), "none"),
  frame: variant("screenshot_frame", ("border", "shadow", "window"), "border"),
  cover-inverse: get(style, "components.cover_inverse", false) == true,
  cta-inverse: get(style, "components.cta_inverse", false) == true,
)

#let brand = (
  name: get(style, "brand.name", "[ЗАПОЛНИТЬ: имя]"),
  role: get(style, "brand.role", "[ЗАПОЛНИТЬ: роль]"),
  telegram: get(style, "brand.telegram", "[ЗАПОЛНИТЬ: telegram]"),
  offer: get(style, "brand.offer", "[ЗАПОЛНИТЬ: оффер]"),
  offer-sub: get(style, "brand.offer_sub", "[ЗАПОЛНИТЬ: подзаголовок оффера]"),
)

#let theme = (
  u: u, colors: colors, normal: pal-normal, inverse: pal-inverse,
  fonts: fonts, label-font: label-font, size: size, shape: shape, comp: comp, brand: brand,
)
