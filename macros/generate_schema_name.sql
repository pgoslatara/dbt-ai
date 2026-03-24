{% macro generate_schema_name(custom_schema_name, node) -%}
    {% if env_var("CI", "false") == "true" %} {{ env_var("DBT_SCHEMA") }}

    {% elif target.name == "prod" and env_var("CI", "false") == "false" %} {{ node.config.schema }}

    {% else %} {{ default__generate_schema_name(custom_schema_name, node) }}

    {%- endif -%}

{%- endmacro %}
