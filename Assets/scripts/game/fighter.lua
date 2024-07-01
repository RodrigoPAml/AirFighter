-- controla player

function fighter.start()
    local this = engine.current()

    -- carrega texturas
    local path = engine.dir.get_assets_path() .. '/images/airplane.png'
    local path_left = engine.dir.get_assets_path() .. '/images/airplane_left.png'
    local path_right = engine.dir.get_assets_path() .. '/images/airplane_right.png'
    local path_life = engine.dir.get_assets_path() .. '/images/life.png'

    local create_args = {
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
    }

    create_args.image_path = path
    this._texture = engine.texture.create(create_args)

    create_args.image_path = path_left
    this._texture_left = engine.texture.create(create_args)

    create_args.image_path = path_right
    this._texture_right = engine.texture.create(create_args)

    create_args.image_path = path_life
    this._texture_life = engine.texture.create(create_args)

    -- carrega limites da camera
    local cam2d = engine.cam2d.get(engine.cam2d.get_current())

    this._max_x = cam2d.right;
    this._max_y = cam2d.top;

    this.x = this._max_x / 2;
    this.y = 100;
    this.size_x = 140
    this.size_y = 190

    -- controle de vida, imunidade e danp
    this.lifes = 3
    this.fires = 1
    this._is_hit = false;
    this._is_immune = false
    this._hit_time = 0;

    -- controle de efeito "piscar"
    this._blink_time = 0;
    this._should_draw = true;
    this._time = engine.time.get_timestamp();
end

function fighter.update()
    -- controla tiro
    fighter.fire()

    -- controle do player
    fighter.control()

    -- detecta se foi acertado e desconta vida ou destruição
    fighter.take_damage()
end

function fighter.on_hit(instance)
    if instance._is_immune then
        return false
    end

    instance._is_hit = true
    return true
end

function fighter.add_life(instance)
    instance.lifes = instance.lifes + 1
end

function fighter.add_damage(instance)
    instance.fires = instance.fires + 1
end

function fighter.take_damage()
    local this = engine.current()

    if (this._is_hit and this._is_immune == false) then
        -- spawn go de explosão onde foi atingido
        local prefabs_father_id = engine.go.find_all('explosions')[1]
        local explosion_prefab_id = engine.go.find_all('explosion_prefab')[1]

        local explosion_id = engine.go.create_copy(explosion_prefab_id, prefabs_father_id)
        engine.go.load_scripts(explosion_id)
        engine.go.set_name(explosion_id, 'explosion')

        local explosion_go = engine.data(explosion_id, 'explosion')
        explosion.init(explosion_go, this.x, this.y)

        this.lifes = this.lifes - 1
        this._is_immune = true
        this._hit_time = engine.time.get_timestamp()

        this._blink_time = this._hit_time
        this._should_draw = false
    end

    -- quando esta imunide controla efeito de "piscar"
    if (this._is_immune) then
        if (this._blink_time + 0.1 < engine.time.get_timestamp()) then
            this._blink_time = engine.time.get_timestamp()
            this._should_draw = not this._should_draw
        end

        local controller_id = engine.go.find_all('controller')[1]
        local controller_go = engine.data(controller_id, 'controller')

        if (this._hit_time + controller_go.immune_time < engine.time.get_timestamp()) then
            this._is_immune = false
            this._is_hit = false
            this._should_draw = true
        end
    end

    if (this.lifes < 0) then
        -- spawn de go de explosão onde foi morto
        local prefabs_father_id = engine.go.find_all('explosions')[1]
        local explosion_prefab_id = engine.go.find_all('explosion_prefab')[1]

        local explosion_id = engine.go.create_copy(explosion_prefab_id, prefabs_father_id)
        engine.go.load_scripts(explosion_id)
        engine.go.set_name(explosion_id, 'explosion')

        local explosion_go = engine.data(explosion_id, 'explosion')
        explosion.init(explosion_go, this.x, this.y)

        engine.go.destroy(engine.go.current())
    end

    fighter.draw_lifes()
end

-- desenha vidas
function fighter.draw_lifes()
    local this = engine.current()

    for i = 1, this.lifes, 1 do
        engine.draw2d.texture({
            position = { x = 30 + ((i - 1) * 60), y = 40 },
            size = { x = 50, y = 50 },
            texture_id = this._texture_life,
        })
    end
end

-- dispara um tiro
function fighter.fire()
    local this = engine.current()

    local has_time_passed = engine.time.get_timestamp() - this._time > 0.1
    local space_input = engine.input.get_key(engine.enums.keyboard_key.space)

    -- se ja pode disparar
    if ((space_input == engine.enums.input_action.press) and has_time_passed) then
        this._time = engine.time.get_timestamp();

        this.fires = math.min(this.fires, 5)

        if this.fires == 1 then
            fighter.spawn_fire(0, 100, true)
        elseif this.fires == 2 then
            fighter.spawn_fire(-15, 100, true)
            fighter.spawn_fire(15, 100, true)
        elseif this.fires == 3 then
            fighter.spawn_fire(0, 100, true)
            fighter.spawn_fire(25, 70, true)
            fighter.spawn_fire(-25, 70, false)
        elseif this.fires == 4 then
            fighter.spawn_fire(15, 70, true)
            fighter.spawn_fire(-15, 70, true)
            fighter.spawn_fire(35, 40, false)
            fighter.spawn_fire(-35, 40, false)
        elseif this.fires == 5 then
            fighter.spawn_fire(0, 90, true)
            fighter.spawn_fire(25, 70, true)
            fighter.spawn_fire(-25, 70, false)
            fighter.spawn_fire(45, 40, false)
            fighter.spawn_fire(-45, 40, false)
        end
    end
end

-- spawn a fire bullet
function fighter.spawn_fire(desloc_x, desloc_y, with_sound)
    local this = engine.current()

    local prefabs_father_id = engine.go.find_all('fighter_fires')[1]
    local fire_prefab_id = engine.go.find_all('fire_prefab')[1]

    local fire_id = engine.go.create_copy(fire_prefab_id, prefabs_father_id)
    engine.go.load_scripts(fire_id)
    engine.go.set_name(fire_id, 'fire')

    local fire_go = engine.data(fire_id, 'fire')
    fire.init(fire_go, this.x - desloc_x, this.y + desloc_y - 15, with_sound)
end

-- contorla player
function fighter.control()
    local this = engine.current()

    -- se saiu da tela
    local limited_xmin = this.x > this._max_x - this.size_x / 2
    local limited_xmax = this.x < 0 + this.size_x / 2
    local limited_ymax = this.y > this._max_y - this.size_y / 2
    local limited_ymin = this.y < 0 + this.size_y / 2

    local up_input = engine.input.get_key(engine.enums.keyboard_key.up)
    local down_input = engine.input.get_key(engine.enums.keyboard_key.down)

    -- movimento para frente e para tras
    if ((up_input == engine.enums.input_action.press) and limited_ymax == false) then
        this.y = this.y + engine.get_frametime()
    elseif ((down_input == engine.enums.input_action.press) and limited_ymin == false) then
        this.y = this.y - engine.get_frametime()
    end

    local left_input = engine.input.get_key(engine.enums.keyboard_key.left)
    local right_input = engine.input.get_key(engine.enums.keyboard_key.right)

    -- movimento para esquerda e direita
    if ((left_input == engine.enums.input_action.press) and limited_xmax == false) then
        this.x = this.x - engine.get_frametime()

        if (this._should_draw) then
            engine.draw2d.texture({
                position = { x = this.x, y = this.y },
                size = { x = this.size_x, y = this.size_y },
                texture_id = this._texture_left,
            })
        end
    elseif ((right_input == engine.enums.input_action.press) and limited_xmin == false) then
        this.x = this.x + engine.get_frametime()

        if (this._should_draw) then
            engine.draw2d.texture({
                position = { x = this.x, y = this.y },
                size = { x = this.size_x, y = this.size_y },
                texture_id = this._texture_right,
            })
        end
    else
        if (this._should_draw) then
            engine.draw2d.texture({
                position = { x = this.x, y = this.y },
                size = { x = this.size_x, y = this.size_y },
                texture_id = this._texture,
            })
        end
    end
end

function fighter.destroy()
    local this = engine.current()

    engine.texture.destroy(this._texture)
    engine.texture.destroy(this._texture_left)
    engine.texture.destroy(this._texture_right)
end
