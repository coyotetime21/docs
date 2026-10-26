# Дизайн-виджеты

Репозиторий для всех моих дизайн-материалов: креды, слайды, карточки и прочее.
Всё верстается на [Typst](https://typst.app) в едином стиле из `style.yaml`.

## Структура

```
style.yaml          стиль: бренд, шрифты, шкала размеров, цвета, формы, варианты компонентов
lib/                общие библиотеки вёрстки
  theme.typ         читает style.yaml → словарь `theme`
  components.typ    мелкие блоки: типографика, заголовки, метрики, теги, карточки, кнопки, фото, QR
  slides.typ        слайды: cover, services, approach, case, testimonials, process, faq, cta
  post.typ          квадратные картинки для постов в Telegram: post-intro, post-solution, post-chat
  site.sh           index.html для страницы виджета на GitHub Pages
fonts/              шрифты (OFL), сборка идёт только с ними
creds/              креды (презентация услуг)
  main.typ          порядок слайдов и настройки страницы
  content.yaml      все тексты
  assets/           фото и скриншоты кейсов (assets/cases/*.png)
  creds.pdf, slide-*.png   результат сборки (в .gitignore)
tg/                 посты для Telegram-канала, один пост = одна папка
  01-logistika/     main.typ, content.yaml, assets/ (логотипы стека), slide-*.png
```

Каждый виджет живёт в своей папке `<виджет>/` с `main.typ`, `content.yaml` и `assets/`
и собирается в эту же папку.

## Сборка

Нужен `typst`.

```sh
make              # PDF и PNG-слайды для creds
make pdf          # только creds/creds.pdf
make png          # только creds/slide-1.png … slide-N.png
make watch        # пересборка PDF при изменениях
make clean        # удалить результаты сборки
make site         # страница для GitHub Pages в build/ (слайды картинками + PDF)
make fonts        # какие шрифты видит typst
make pdf DIR=xxx  # собрать другой виджет: xxx/main.typ → xxx/xxx.pdf
make tg           # картинки всех постов: tg/<пост>/slide-*.png, 2160×2160
```

## Публикация

При пуше в `main` (если менялись `creds/`, `lib/`, `fonts/`, `style.yaml` или `Makefile`)
GitHub Actions (`.github/workflows/build.yml`) выполняет `make site` и выкладывает `build/` на GitHub Pages:
креды открываются по ссылке `https://coyotetime21.github.io/docs/creds/`.
Собранные файлы также лежат в артефакте `creds` запуска workflow (90 дней).

## Как править

- **Тексты** правятся в `creds/content.yaml`. Неразрывные пробелы расставляются сами.
  Заглушки `[ЗАПОЛНИТЬ: …]` на слайдах подсвечиваются голубым.
- **Стиль** (цвета, шрифты, размеры, варианты карточек, тегов и кнопок) задаётся только в `style.yaml`.
- **Раскладка** правится в `creds/main.typ`: именованные параметры слайдов из `lib/slides.typ`
  можно передать прямо в вызов, например `#cover(c.cover, columns: (2fr, 1fr))`.
- **Картинки** кладутся в `creds/assets/`, путь в `content.yaml` пишется от корня проекта:
  `creds/assets/cases/x.png`. Если вместо пути указать `none`, на слайде будет заглушка с подсказкой.
- **Кейсы**: один блок в `cases` — один слайд. Слайд с отзывами появляется при двух отзывах и больше,
  FAQ (`faq.enabled: auto`) — когда кейсов меньше трёх.
- **Посты в Telegram**: новый пост — папка `tg/<номер>-<тема>/` со своими `main.typ` и `content.yaml`
  (удобно скопировать `tg/01-logistika/`). Картинки квадратные 2160×2160: в альбоме из трёх фото
  Telegram показывает их без обрезки. Логотипы стека — одноцветные SVG (Simple Icons),
  перекрашиваются в цвет текста из `style.yaml`.
