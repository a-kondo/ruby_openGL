require "glut"
require "glu"
require "gl"

class Point
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Sample 
  def disp()
    puts "disp"
    GL.Clear(GL::COLOR_BUFFER_BIT)
=begin for mouse point line connected case
    for i in 0..@points.length-2
      GL.Color3d(0.0, 0.0, 0.0)
      GL.Begin(GL::POLYGON)
      GL.Vertex2d(@points[i].x, @points[i].y)
      GL.Vertex2d(@points[i+1].x, @points[i+1].y)
      GL.End()
    end
=end
    GL.Color3d(0.0, 0.0, 0.0)
    GL.Begin(GL::LINES)
    for i in 0..11
      GL.Vertex3dv(@vertex[@edge[i][0]])
      GL.Vertex3dv(@vertex[@edge[i][1]])
    end
    GL.End()
    GL.Flush()
  end

  def idle()
    GLUT.PostRedisplay()
  end

  def resize(w, h)
    GL.Viewport(0, 0, w, h)
    GL.LoadIdentity()
    #GL.Ortho(-w/@width, w/@width, -h/@height, h/@height, -1.0, 1.0)
    #GL.Ortho(-0.5, w-0.5, h-0.5, -0.5, -1.0, 1.0)
    #GL.Ortho(-2.0, 2.0, -2.0, 2.0, -2.0, 2.0)
    GLU.Perspective(30.0, w/h, 1.0, 100.0)
    GLU.LookAt(3.0, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
  end

  def mouse(button, state, x, y)
    case button
    when GLUT::LEFT_BUTTON
      if state == GLUT::UP
        if !@points.empty?
          GL.Color3d(0.0, 0.0, 0.0)
          GL.Begin(GL::POLYGON)
          GL.Vertex2d(@points[@points.length-1].x, @points[@points.length-1].y)
          GL.Vertex2d(x, y)
          GL.End()
          GL.Flush()
        end
        point = Point.new(x, y)
        @points.push(point)
      else
        # do nothing
      end
    when GLUT::RIGHT_BUTTON
      puts "right button is pushed #{x} #{y}"
    end
  end

  def motion(x, y)
=begin
    GL.Enable(GL::COLOR_LOGIC_OP)
    GL.LogicOp(GL::INVERT)

    GL.Begin(GL::LINES)
    GL.Vertex2i(@points[@points.length-1].x, @points[@points.length-1].y)
    GL.Vertex2i(x, y)
    GL.End()
    GL.Flush()

    GL.LogicOp(GL::COPY)
    GL.Disable(GL::COLOR_LOGIC_OP)
=end
    puts "in motion #{x} #{y}"
  end

  def keyboard(key, x, y)
    puts "#{key}"
    case key
    when 'q'
      exit()
    when '\033' # ESC but It's not \033, and no print ESC
      exit()
    end
  end

  def init()
    @points = []
    @width = 300.0
    @height = 200.0
    @mouse_on_x = 0
    @mouse_on_y = 0
    @vertex = [
      [0.0, 0.0, 0.0],
      [1.0, 0.0, 0.0],
      [1.0, 1.0, 0.0],
      [0.0, 1.0, 0.0],
      [0.0, 0.0, 1.0],
      [1.0, 0.0, 1.0],
      [1.0, 1.0, 1.0],
      [0.0, 1.0, 1.0]
    ]
    @edge = [
      [0, 1],
      [1, 2],
      [2, 3],
      [3, 0],
      [4, 5],
      [5, 6],
      [6, 7],
      [7, 4],
      [0, 4],
      [1, 5],
      [2, 6],
      [3, 7]
    ]
    @r = 0

    GLUT.InitWindowPosition(500, 500)
    GLUT.InitWindowSize(@width, @height)
    
    GLUT.Init()
    GLUT.InitDisplayMode(GLUT::RGBA)
    GLUT.CreateWindow("sample window")
    GLUT.DisplayFunc(method(:disp).to_proc())
    GLUT.ReshapeFunc(method(:resize).to_proc())
    GLUT.MouseFunc(method(:mouse).to_proc())
    GLUT.MotionFunc(method(:motion).to_proc())
    GLUT.KeyboardFunc(method(:keyboard).to_proc())
    GL.ClearColor(1.0, 1.0, 1.0, 1.0)
    GLUT.MainLoop()
  end

end

sample = Sample.new
sample.init()