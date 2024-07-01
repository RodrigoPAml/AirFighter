-- desenha nuvens

function clouds.start()
    local this = engine.current()

    -- carrega imagem de nuvem
    local cloud = engine.dir.get_assets_path() .. '/images/' .. this.path
    this._texture_id = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = cloud
    })
    
    -- limitações da tela
    local cam2d = engine.cam2d.get(engine.cam2d.get_current())
    this._max_x = cam2d.right;
    this._max_y = cam2d.top;

    -- seta tamanho inicial, velocidade e ponto de termino da nuvem
    this._size = math.max(1000, this._max_x * 2.5 * engine.math.random())
    this._vel = engine.math.random() * 3
    this._exit_point = this._max_y * 2
end

function clouds.update()
    local this = engine.current()

    -- move a nuvem
    this.y = this.y - ((engine.get_frametime() / 3) * this._vel)

    -- desenha nuvem
    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this._size, y = this._size },
        texture_id = this._texture_id,
    })

    -- quand passar no ponto de termino reinicia a posição da nuvem para aparecer na tela novamente
    if this.y <= -(this._exit_point) then
        this.x = engine.math.random() * this._max_x
        this.y = engine.math.random() * 2000 + 3000

        this._size = math.max(1000, this._max_x * 2.5 * engine.math.random())
        this._exit_point = engine.math.random() * 3000 + (this._max_y * 2)
    end
end

function clouds.destroy()
    local this = engine.current()
    engine.texture.destroy(this._texture_id)
end
