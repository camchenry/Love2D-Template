local function rk4_evaluate(initial, dt, deriv)
    local state = {}
    state.position = initial.position + deriv.velocity * dt
    state.velocity = initial.velocity + deriv.acceleration * dt

    local newDeriv = {}
    newDeriv.velocity = state.velocity
    newDeriv.acceleration = initial.acceleration

    return newDeriv
end

-- Runge-Kutta order 4 integration
local function rk4_integrate(state, dt)
    local deriv = {
        velocity = Vector(),
        acceleration = Vector(),
    }
    local a = rk4_evaluate(state, 0, deriv)
    local b = rk4_evaluate(state, dt*0.5, a)
    local c = rk4_evaluate(state, dt*0.5, b)
    local d = rk4_evaluate(state, dt, c)

    -- velocity / delta time
    local dxdt = 1/6 * (a.velocity + 2 * (b.velocity + c.velocity) + d.velocity)
    -- acceleration / delta time
    local dvdt = 1/6 * (a.acceleration + 2 * (b.acceleration + c.acceleration) + d.acceleration)

    state.position = state.position + dxdt * dt
    state.velocity = state.velocity + dvdt * dt
end

local function euler_integrate(state, dt)
    state.velocity = state.velocity + state.acceleration * dt
    state.position = state.position + state.velocity * dt 
end

local PhysicsBody = Class("PhysicsBody")

function PhysicsBody:initialize(x, y)
    self.position = Vector(x, y)
    self.velocity = Vector()
    self.acceleration = Vector()

    -- Gravity applied to acceleration every update
    self.gravity = Vector()

    -- Velocity damping (friction)
    self.damping = Vector()

    -- Velocity units greater than this will be floored to this value
    self.maxForce = 10000

    -- Velocity units less than this will be floored to zero
    self.minForce = 0.0001
end

function PhysicsBody:update(dt)
    self.acceleration = self.acceleration + self.gravity

    rk4_integrate(self, dt)

    -- Clamp velocity to max value
    self.velocity:trimInplace(self.maxForce)

    -- Velocity damping (friction)
    self.velocity.x = self.velocity.x * math.pow(1 - self.damping.x, dt)
    self.velocity.y = self.velocity.y * math.pow(1 - self.damping.y, dt)

    -- Flooring velocity
    self.velocity.x = math.abs(self.velocity.x) < self.minForce and 0 or self.velocity.x
    self.velocity.y = math.abs(self.velocity.y) < self.minForce and 0 or self.velocity.y

    self.acceleration.x = 0
    self.acceleration.y = 0
end

function PhysicsBody:draw()

end

function PhysicsBody:applyLinearImpulse(impulse)
    self.velocity = self.velocity + impulse
end

function PhysicsBody:applyForce(force)
    self.acceleration = self.acceleration + force
end

function PhysicsBody:setAcceleration(accel)
    self.acceleration = accel
end

function PhysicsBody:setVelocity(vel)
    self.velocity = vel
end

function PhysicsBody:setPosition(pos)
    self.position = pos
end

function PhysicsBody:getAcceleration()
    return self.acceleration
end

function PhysicsBody:getVelocity()
    return self.velocity
end

function PhysicsBody:getPosition()
    return self.position
end

return PhysicsBody
