{application, 'cache', [
	{description, "New project"},
	{vsn, "0.1.0"},
	{modules, ['cache','cache_app','cache_sup']},
	{registered, [cache_sup]},
	{applications, [kernel,stdlib]},
	{mod, {cache_app, []}},
	{env, []}
]}.