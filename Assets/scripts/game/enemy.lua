-- script que controla inimigo 

function enemy.start()
    local this = engine.current()

    -- load enemy texture
    this._texture_id = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_enemy

    local cam2d = engine.cam2d.get(engine.cam2d.get_current())

    -- limits of movement
    this._max_x = cam2d.right;
    this._max_y = cam2d.top;

    -- intial position
    this.x = engine.math.random() * this._max_x;
    this.y = this._max_y + 100;

    this.size_x = 150
    this.size_y = 150

    enemy.start_attributes()
end

-- quando toma dano externo
function enemy.on_hit(instance)
    instance.lifes = instance.lifes - 1
    instance._is_hit = true
end

-- inicializa atributos
function enemy.start_attributes()
    local this = engine.current()
    local controller_id = engine.go.find_all('controller')[1]
    local controller_go = engine.data(controller_id, 'controller')

    -- velocidade
    this._vel_y = controller_go.enemy_vel_y
    this._vel_x = controller_go.enemy_vel_x

    -- direção de movimento
    if (engine.math.random() > 0.5) then
        this._vel_x = this._vel_x * -1
    end

    -- intervalo de rajada de tiros
    this._interval_of_fire = controller_go.enemy_interval_of_fire

    -- tempo entre tiros da rajada
    this._fire_rate = controller_go.enemy_fire_rate

    this._last_fire_time = engine.time.get_timestamp()
    this._fire_time = engine.time.get_timestamp()
    this._should_fire = true

    -- vida inicial
    this.lifes = controller_go.enemy_life
    this._is_hit = false
end

function enemy.update()
    local this = engine.current()

    enemy.control()
    enemy.deal_damage()
    enemy.take_damage()
    enemy.collide_fighter()

    if (this._is_hit) then
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_id,
            color = { x = 0.5, y = 0, z = 0, w = 0 },
            color_weight = 0.5
        })

        this._is_hit = false
    else
        -- deseha inimigo
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_id,
        })
    end
end

-- controla inimigo
function enemy.control()
    local this = engine.current()
    local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')

    if (fighter_go == nil) then
        return
    end

    if (this.y > this._max_y / 0.5) then
        this.y = this.y - (engine.get_frametime() * this._vel_y)
        this.x = this.x - (engine.get_frametime() * this._vel_x)
    -- comportamento agressivo
    else
        this.y = this.y - (engine.get_frametime() * this._vel_y)

        if (fighter_go.x > this.x) then
            this.x = this.x + (engine.get_frametime() * math.abs(this._vel_x))
        elseif fighter_go.x < this.x then
            this.x = this.x - (engine.get_frametime() * math.abs(this._vel_x))
        end
    end

    -- não deixa inimigo sair da tela pelos lados
    if (this.x < 0) then
        this._vel_x = this._vel_x * -1
        this.x = 0
    elseif (this.x > this._max_x) then
        this.x = this._max_x
        this._vel_x = this._vel_x * -1
    end

    -- se sair da tela, retorna ao inicio
    if (this.y < -100) then
        this.y = this._max_y + 200
    end
end

-- colisão com player
function enemy.collide_fighter()
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
    if fighter.on_hit(fighter_go) then
        -- e se auto destroi
        this.lifes = 0
    end
end

-- atira disparos
function enemy.deal_damage()
    local this = engine.current()

    -- calcula quando pode atirar
    if (engine.time.get_timestamp() > this._fire_time + this._interval_of_fire) then
        this._fire_time = engine.time.get_timestamp()
        this._last_fire_time = engine.time.get_timestamp()
        this._should_fire = not this._should_fire
    end

    if (this._should_fire == true) then
        if (engine.time.get_timestamp() > this._last_fire_time + this._fire_rate) then
            local fire_prefab_id = engine.go.find_all('enemy_fire_prefab')[1]
            local fire_father_id = engine.go.find_all('enemy_fires')[1]

            local new_go_id = engine.go.create_copy(fire_prefab_id, fire_father_id)
            engine.go.load_scripts(new_go_id)

            local new_go = engine.data(new_go_id, 'enemy_fire')
            engine.go.set_name(new_go_id, 'enemy_fire')

            enemy_fire.init(new_go, this.x + 16, this.y - 30)
            this._last_fire_time = engine.time.get_timestamp()
        end
    end
end

-- calcula perda de vida
function enemy.take_damage()
    local this = engine.current()

    -- se morrer se destroy
    if (this.lifes <= 0) then
        -- avisa ao controlador de matou inimigo
        local controller_go = engine.data(engine.go.find_all('controller')[1], 'controller')
        controller.on_enemy_killed(controller_go)

        -- se destroy
        engine.go.destroy(engine.go.current())

        -- spawn de explosão onde morreu
        local explosion_id = engine.go.create_copy(engine.go.find_all('explosion_prefab')[1], engine.go.find_all('explosions')[1])
        engine.go.load_scripts(explosion_id)
        engine.go.set_name(explosion_id, 'explosion')

        local explosion_go = engine.data(explosion_id, 'explosion')
        explosion.init(explosion_go, this.x, this.y)
    end
end