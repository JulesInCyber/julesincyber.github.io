---
layout: page
icon: fas fa-gear
order: 5
permalink: /projects/
---

{% for project in site.project %}
  <article>
    <h2><a href="{{ project.url }}">{{ project.title }}</a></h2>
    <p>{{ project.excerpt }}</p>
  </article>
{% endfor %}
