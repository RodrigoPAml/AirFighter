-- desenha props do cenario

function props.start()
    local this = engine.current()

    -- carrega imagem de nuvem
    local image = engine.dir.get_assets_path() .. '/images/' .. this.path
    this._texture_id = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = image
    })
    
    -- limitações da tela
    local cam2d = engine.cam2d.get(engine.cam2d.get_current())
    this._max_x = cam2d.right;
    this._max_y = cam2d.top;

    this._exit_point = this._max_y + this.size_x
    
    if not this.velocity then
        this._vel = engine.math.random() * this.max_vel
    else 
        this._vel = this.velocity
    end

    this.x = engine.math.random() * this._max_x
    this.y = engine.math.random() * this.y_fade_multiplier + this.min_y_fade
end

function props.update()
    local this = engine.current()

    -- move o prop
    this.y = this.y - engine.get_frametime() * this._vel

    -- desenha prop
    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this.size_x, y = this.size_y },
        texture_id = this._texture_id,
        rotation = this.rotation,
    })

    -- quand passar no ponto de termino reinicia a posição da nuvem para aparecer na tela novamente
    if this.y <= -(this._exit_point) then
        this.x = engine.math.random() * this._max_x
        this.y = engine.math.random() * this.y_fade_multiplier + this.min_y_fade

        this._exit_point = engine.math.random() * 1000 + (this._max_y * 2)
    end
end

function props.destroy()
    local this = engine.current()
    engine.texture.destroy(this._texture_id)
end
