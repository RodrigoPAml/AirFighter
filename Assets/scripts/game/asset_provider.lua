-- script que fornece texturas para outros scripts
function asset_provider.start()
    asset_provider.alloc_enemy_fire()
    asset_provider.alloc_fire()
    asset_provider.alloc_enemy()
    asset_provider.alloc_explosion()
    asset_provider.alloc_boss_fire()
end

function asset_provider.alloc_explosion()
    local this = engine.current()

    local path1 = engine.dir.get_assets_path() .. '/images/boom1.png'
    local path2 = engine.dir.get_assets_path() .. '/images/boom2.png'
    local path3 = engine.dir.get_assets_path() .. '/images/boom3.png'
    local path4 = engine.dir.get_assets_path() .. '/images/boom4.png'

    local create_args = {
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
    }

    create_args.image_path = path1
    this.texture_explosion_1 = engine.texture.create(create_args)

    create_args.image_path = path2
    this.texture_explosion_2 = engine.texture.create(create_args)

    create_args.image_path = path3
    this.texture_explosion_3 = engine.texture.create(create_args)

    create_args.image_path = path4
    this.texture_explosion_4 = engine.texture.create(create_args)
end

function asset_provider.alloc_fire()
    local this = engine.current()
    local path = engine.dir.get_assets_path() .. '/images/fire.png'

    this.texture_fire = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = path
    })
end

function asset_provider.alloc_enemy()
    local this = engine.current()
    local path = engine.dir.get_assets_path() .. '/images/enemy.png'

    this.texture_enemy = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = path
    })
end

function asset_provider.alloc_enemy_fire()
    local this = engine.current()

    local path = engine.dir.get_assets_path() .. '/images/enemy_fire.png'
    this.texture_laser_enemy = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = path
    })
end

function asset_provider.alloc_boss_fire()
    local this = engine.current()

    local path = engine.dir.get_assets_path() .. '/images/energy.png'
    this.texture_laser_boss = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.clamp_to_edge,
        ansiotropic_filter = 8,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = path
    })
end