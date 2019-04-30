require "glut"
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
    GL.Clear(GL::COLOR_BUFFER_BIT)
    for i in 0..@points.length-2
      GL.Color3d(0.0, 0.0, 0.0)
      GL.Begin(GL::LINES)
      GL.Vertex2i(@points[i].x, @points[i].y)
      GL.Vertex2i(@points[i+1].x, @points[i+1].y)
      GL.End()
    end
    GL.Flush()
  end

  def resize(w, h)
    GL.Viewport(0, 0, w, h)
    GL.LoadIdentity()
    #GL.Ortho(-w/@width, w/@width, -h/@height, h/@height, -1.0, 1.0)
    GL.Ortho(-0.5, w-0.5, h-0.5, -0.5, -1.0, 1.0)
  end

  def mouse(button, state, x, y)
    case button
    when GLUT::LEFT_BUTTON
      if state == GLUT::UP
        if !@points.empty?
          GL.Color3d(0.0, 0.0, 0.0)
          GL.Begin(GL::LINES)
          GL.Vertex2i(@points[@points.length-1].x, @points[@points.length-1].y)
          GL.Vertex2i(x, y)
          GL.End()
          GL.Flush()
        end
        point = Point.new(x, y)
        @points.push(point)
      else
        # do nothing
      end
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

    GLUT.InitWindowPosition(100, 100)
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