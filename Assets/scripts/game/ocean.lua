-- desenha oceano

function ocean.start()
    local this = engine.current()

    -- carrega textura do oceano
    local assetsPath = engine.dir.get_assets_path() .. '/images/ocean.png'
    this._texture_id = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = assetsPath
    })

    local cam2d = engine.cam2d.get(engine.cam2d.get_current())

    -- limitações da camera
    this._size_x = cam2d.right;
    this._size_y = cam2d.top;

    -- controla posição das duas imagens que formam a imagem infinita
    this.x = 0;
    this.y = 0;
    this.y2 = this._size_y * 2;
end

function ocean.update()
    local this = engine.current()

    -- primeira textura
    _draw2d_.texture({
        position = { x = this.x + this._size_x / 2, y = this.y },
        size = { x = this._size_x, y = this._size_y * 2 },
        texture_id = this._texture_id,
    })

    -- segunda textura
    _draw2d_.texture({
        position = { x = this.x + this._size_x / 2, y = this.y2 },
        size = { x = this._size_x, y = this._size_y * 2 },
        texture_id = this._texture_id,
    })

    -- move imagens
    this.y = this.y - engine.get_frametime() / 6;
    this.y2 = this.y2 - engine.get_frametime() / 6;

    -- poem imagens na posição inicial novamente
    if this.y <= -(this._size_y * 2) then
        this.y = this.y2 + (this._size_y * 2)
    end

    if this.y2 <= -(this._size_y * 2) then
        this.y2 = this.y + this._size_y * 2
    end
end

function ocean.destroy()
    local this = engine.current()
    engine.texture.destroy(this._texture_id)
end
