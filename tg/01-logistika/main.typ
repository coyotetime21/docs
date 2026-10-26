#import "/lib/theme.typ": theme
#import "/lib/post.typ": *

#let c = yaml("content.yaml")

#set document(title: theme.brand.name + " — пост: кейс логистика", author: theme.brand.name)
#show: post-page

#post-intro(c.intro)
#post-solution(c.solution)
#post-chat(c.chat)
