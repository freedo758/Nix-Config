return {
image = "{{ image }}",
{%- for name, value in colors.items() %}
{{ name }} = "0xff{{ value.default.hex_stripped }}"{% if not loop.last %},{% endif %}
{%- endfor %}
}