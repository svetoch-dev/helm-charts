The argument definitions in `templates/args/` adapt Apache-2.0 code from
[Bitnami Thanos chart 17.3.1](https://github.com/bitnami/charts/tree/thanos/17.3.1/bitnami/thanos).
The source path is recorded in each definition. Changes adapt values scoping,
helper names, and indentation, omit automatic HTTP server configuration, and
preserve the existing ruler validation.
The shared helpers also adapt query URL and secret-key helper behavior.
The upstream copyright notice and license are retained in
`bitnami-thanos-LICENSE.md`.
