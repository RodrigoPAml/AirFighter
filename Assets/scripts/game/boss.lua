-- script que controla inimigo

function boss.start()
    local this = engine.current()
    local path = engine.dir.get_assets_path() .. '/images/boss.png'

    -- carrega textura
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

    local controller_id = engine.go.find_all('controller')[1]
    local controller_go = engine.data(controller_id, 'controller')

    -- limites de movimento
    this._max_x = cam2d.right;
    this._max_y = cam2d.top;

    -- posição inicial
    this.x = this._max_x / 2;
    this.y = this._max_y + 500;

    -- vida inicial
    this.life = controller_go.boss_life
    this._initial_life = this.life

    -- tamanho e movimento
    this.size_x = 200
    this.size_y = 250
    this._dir_left = true;

    -- controle de tiro
    this._last_fire_time = engine.time.get_timestamp()
    this._fire_time = engine.time.get_timestamp()
    this._should_fire = true
    this._is_hit = false

    this._interval_of_fire = controller_go.boss_interval_of_fire
    this._fire_rate = controller_go.boss_fire_rate

    -- controle de modo especial
    this._invisible = false
    this._next_especial = engine.time.get_timestamp() + 10
    this._life_special = false
end

-- quando toma dano externo
function boss.on_hit(instance)
    instance.life = instance.life - 1
    instance._is_hit = true
end

function boss.update()
    boss.move()
    boss.show_life()
    boss.draw()
    boss.collide_fighter()
    boss.deal_damage()
    boss.special()
    boss.take_damage()
end

function boss.can_hit(instance)
    return not instance._invisible
end

-- desenha boss
function boss.draw()
    local this = engine.current()

    local transparency = 1

    if (this._invisible) then
        transparency = 0.1
    end

    if (this._is_hit) then
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_id,
            color = { x = 0.5, y = 0, z = 0, w = 0 },
            color_weight = 0.5,
            transparency = transparency
        })

        this._is_hit = false
    else
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_id,
            color = { x = 0, y = 0, z = 0, w = 0 },
            transparency = transparency
        })
    end
end

function boss.special()
    local this = engine.current()

    local controller_id = engine.go.find_all('controller')[1]
    local controller_go = engine.data(controller_id, 'controller')

    if this.life < 50 and not this._life_special then
        this._life_special = true
        this._invisible = true
        this._next_especial = engine.time.get_timestamp() + 6 -- desativa depois de x segundos

        this._interval_of_fire = controller_go.boss_interval_of_fire_rage
        this._fire_rate = controller_go.boss_fire_rate_rage
        this._fire_time = engine.time.get_timestamp() + 10000000
        this._last_fire_time = engine.time.get_timestamp()
        this._should_fire = true
    end

    -- ativa especial
    if (not this._invisible and this._next_especial < engine.time.get_timestamp() and not this._life_special) then
        this._invisible = true
        this._next_especial = engine.time.get_timestamp() + 6 -- desativa depois de x segundos

        this._interval_of_fire = controller_go.boss_interval_of_fire_special
        this._fire_rate = controller_go.boss_fire_rate_special
        this._fire_time = engine.time.get_timestamp() + 100
        this._last_fire_time = engine.time.get_timestamp()
        this._should_fire = true
    end

    -- desativa especial
    if this._invisible and this._next_especial < engine.time.get_timestamp() then
        this._invisible = false
        this._next_especial = engine.time.get_timestamp() + 25 -- ativa depois de x segundos

        this._interval_of_fire = controller_go.boss_interval_of_fire
        this._fire_rate = controller_go.boss_fire_rate
        this._fire_time = engine.time.get_timestamp() - this._interval_of_fire
        this._last_fire_time = engine.time.get_timestamp()
        this._should_fire = false

        -- spawn lifes
        local new_id = engine.go.create_copy(engine.go.find_all('life_prefab')[1], engine.go.find_all('lifes')[1])
        engine.go.set_name(new_id, 'life')
    end
end

-- mostra vida
function boss.show_life()
    local this = engine.current()

    if (this._invisible) then
        return

    end
    
    engine.command.set_primitive_line_size(1)

    engine.draw2d.rect({
        position = { x = this.x, y = this.y + this.size_y / 2 + 30 },
        size = { x = 100, y = 20 },
        color = { x = 1, y = 0, z = 0, w = 1 },
        filled = false,
    })

    local life_percentage = this.life / this._initial_life
    local life_width = 100 * life_percentage

    engine.draw2d.rect({
        position = { x = this.x, y = this.y + this.size_y / 2 + 30 },
        size = { x = life_width, y = 20 },
        color = { x = 0, y = 1, z = 0, w = 1 },
        filled = true,
    })
end

-- move chefe
function boss.move()
    local this = engine.current()

    if (this.y > this._max_y / 1.25) then
        this.y = this.y - (engine.get_frametime() / 3)
    else
        if (this._dir_left) then
            this.x = this.x - (engine.get_frametime() / 5)
        else
            this.x = this.x + (engine.get_frametime() / 5)
        end
    end

    if this.x < this.size_x then
        this._dir_left = false
    end

    if this.x > this._max_x - this.size_x then
        this._dir_left = true
    end
end

-- colisão com player
function boss.collide_fighter()
    local this = engine.current()
    local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')

    if (fighter_go == nil) then
        return
    end

    -- calcula bounding box do player
    local max_x = this.x + this.size_x / 2 - 30
    local min_x = this.x - this.size_x / 2 + 30

    local max_x_fighter = fighter_go.x + fighter_go.size_x / 2
    local min_x_fighter = fighter_go.x - fighter_go.size_x / 2

    if max_x < min_x_fighter or max_x_fighter < min_x then
        return
    end

    -- calcula bounding box do inimigo
    local max_y = this.y + this.size_y / 2 - 30
    local min_y = this.y - this.size_y / 2 + 30

    local max_y_fighter = fighter_go.y + fighter_go.size_y / 2
    local min_y_fighter = fighter_go.y - fighter_go.size_y / 2

    if max_y < min_y_fighter or max_y_fighter < min_y then
        return
    end

    -- tenta acertar player
    fighter.on_hit(fighter_go)
end

-- atira disparos
function boss.deal_damage()
    local this = engine.current()

    -- calcula quando pode atirar
    if (engine.time.get_timestamp() > this._fire_time + this._interval_of_fire) then
        this._fire_time = engine.time.get_timestamp()
        this._last_fire_time = engine.time.get_timestamp()
        this._should_fire = not this._should_fire
    end

    if (this._should_fire == true) then
        if (engine.time.get_timestamp() > this._last_fire_time + this._fire_rate) then
            local fire_prefab_id = engine.go.find_all('boss_fire_prefab')[1]
            local fire_father_id = engine.go.find_all('boss_fires')[1]

            local controller_id = engine.go.find_all('controller')[1]
            local controller_go = engine.data(controller_id, 'controller')

            for i = 1, controller_go.boss_fire_number do
                local vector = { x = (engine.math.random() * 2) - 1, y = engine.math.random() }
                local magnitude = math.sqrt(vector.x ^ 2 + vector.y ^ 2)
                local normalizedVector = {
                    x = vector.x / magnitude,
                    y = vector.y / magnitude,
                }

                local new_go_id = engine.go.create_copy(fire_prefab_id, fire_father_id)
                engine.go.load_scripts(new_go_id)

                local new_go = engine.data(new_go_id, 'boss_fire')
                engine.go.set_name(new_go_id, 'boss_fire')

                boss_fire.init(new_go, this.x + 16, this.y - 30, normalizedVector.x, normalizedVector.y)
            end


            this._last_fire_time = engine.time.get_timestamp()
        end
    end
end

-- calcula perda de vida
function boss.take_damage()
    local this = engine.current()

    -- se morrer se destroy
    if (this.life <= 0) then
        -- se destroy
        engine.go.destroy(engine.go.current())

        -- spawn de explosão onde morreu
        local explosion_id = engine.go.create_copy(engine.go.find_all('explosion_prefab')[1],
            engine.go.find_all('explosions')[1])
        engine.go.load_scripts(explosion_id)
        engine.go.set_name(explosion_id, 'explosion')

        local explosion_go = engine.data(explosion_id, 'explosion')
        explosion.init(explosion_go, this.x, this.y)
    end
end

function boss.destroy()
    local this = engine.current()
    engine.texture.destroy(this._texture_id)
end
