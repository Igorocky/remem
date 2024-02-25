module type BeFunction = {
    let name: string
    type req
    type res
}

// https://forum.rescript-lang.org/t/how-to-use-the-first-class-module-in-rescript/3238/5
type beFuncModule<'req,'res> = module(BeFunction with type req = 'req and type res = 'res)

