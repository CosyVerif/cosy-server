local Test = require "cosy.server.test"

describe ("cosyverif api", function ()
  Test.environment.use ()

  local request
  local app

  before_each (function ()
    Test.clean_db ()
    request = Test.environment.request ()
    app     = Test.environment.app ()
  end)

  it ("accepts scenario #1", function ()
    local status, result
    local token = Test.make_token (Test.identities.rahan)
    -- Create the user:
    status, result = request (app, "/", {
      method  = "GET",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 200)
    local user = result.authentified
    -- Update user info:
    status = request (app, "/users/" .. user.id, {
      method  = "PATCH",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 204)
    -- Create a project:
    status, result = request (app, "/projects", {
      method  = "POST",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 201)
    local project = result.url
    -- Star project:
    status = request (app, project .. "/stars", {
      method  = "PUT",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 201)
    -- Tag project:
    status = request (app, project .. "/tags/mytag", {
      method  = "PUT",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 201)
    -- Get user:
    status = request (app, "/users/" .. user.id, {
      method  = "GET",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 200)
    -- print (result)
    -- Get all users:
    status = request (app, "/users", {
      method  = "GET",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 200)
    -- print (result)
    -- Delete user:
    status = request (app, "/users/" .. user.id, {
      method  = "DELETE",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 204)
    -- Check that user has been deleted:
    status = request (app, "/users/" .. user.id, {
      method  = "GET",
      headers = { Authorization = "Bearer " .. token },
    })
    assert.are.same (status, 404)
  end)

end)
