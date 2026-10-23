// main.typ — только сборка: настройки страницы и порядок слайдов.
// Тексты: creds/content.yaml. Стиль: style.yaml. Вёрстка: lib/.

#import "/lib/theme.typ": theme
#import "/lib/slides.typ": *

#let c = yaml("content.yaml")

#set document(title: theme.brand.name + " — креды", author: theme.brand.name)
#set page(width: 1280pt, height: 720pt, margin: (y: theme.shape.pad-y, x: theme.shape.pad-x))
#set text(
  lang: "ru",
  font: theme.fonts.body.family,
  weight: theme.fonts.body.weight,
  size: theme.size.body,
  fill: theme.normal.text,
  hyphenate: false,
)

#let cases = c.at("cases", default: ())
#let reviews = c.at("testimonials", default: ())
#let faq-on = {
  let mode = c.faq.at("enabled", default: "auto")
  if mode == "auto" { cases.len() < 3 } else { mode == true }
}

#cover(c.cover)
#services(c.services)
// Кейсы чередуются: текст справа, слева, справа…
// Широкий скриншот (дашборд): колонка шире, высота по картинке, без обрезки.
#let wide-shot = (columns: (1fr, 1.25fr), shot-height: auto)
#for (i, item) in cases.enumerate() {
  let wide = item.at("screenshot", default: none) == "creds/assets/cases/sales.png"
  case(item, n: i + 1, flip: calc.odd(i), ..if wide { wide-shot } else { (:) })
}
#if reviews.len() >= 2 { testimonials(c.testimonials_slide, reviews) }
#process(c.process)
#if faq-on { faq(c.faq) }
#cta(c.cta, c.telegram_url)
