-- controla item de dano oferecido ao player

function damage.start()
    local this = engine.current()
    local path = engine.dir.get_assets_path() .. '/images/damage.png'

    this._texture_id = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = path
    })

    local cam2d = engine.cam2d.get(engine.cam2d.get_current())

    -- posição inicial
    this.x = engine.math.random() * cam2d.right;
    this.y = cam2d.top + 100;

    this.size_x = 55
    this.size_y = 55
end

function damage.update()
    local this = engine.current()
    
    -- move
    this.y = this.y - (engine.get_frametime() * 0.2)
    
    -- desenha
    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this.size_x, y = this.size_y },
        texture_id = this._texture_id,
    })

    -- saindo a tela no y se destroy
    if (this.y < -100) then
        engine.go.destroy(engine.go.current())
    end

    damage.collide()
end

-- trata colisão com player
function damage.collide()
    local this = engine.current()

    -- colisão com player
    local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')

    if (fighter_go == nil) then
        return
    end

    -- calcula bouding box no x
    local max_x = fighter_go.x + fighter_go.size_x / 2
    local min_x = fighter_go.x - fighter_go.size_x / 2

    if (this.x > min_x and this.x < max_x) then
        -- calcula bounding box no y
        local max_y = fighter_go.y + fighter_go.size_y / 2
        local min_y = fighter_go.y - fighter_go.size_y / 2

        if (this.y > min_y and this.y < max_y) then
            fighter.add_damage(fighter_go)
            engine.go.destroy(engine.go.current())
        end
    end
end

function damage.destroy()
    local this = engine.current()
    engine.texture.destroy(this._texture_id)
end
