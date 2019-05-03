require "glut"
require "glu"
require "gl"

module Color
  BLACK = [0.0, 0.0, 0.0] 
  WHITE = [1.0, 1.0, 1.0]
  RED = [1.0, 0.0, 0.0]
  GREEN = [0.0, 1.0, 0.0]
  BLUE = [0.0, 0.0, 1.0]
end

class Point
  attr_reader :x
  attr_reader :y

  def initialize(x, y)
    @x = x
    @y = y
  end
end

class Link
  attr_reader :start_node, :end_node
  attr_accessor :line_color, :node_color
  @@node_size = 5

  def draw
    GL.PointSize(@@node_size)
    GL.Begin(GL::POINTS)
    GL.Color3dv(@node_color)
    GL.Vertex3fv(@start_node)
    GL.Vertex3fv(@end_node)
    GL.End()

    GL.Begin(GL::LINES)
    GL.Color3dv(@line_color)
    GL.Vertex3fv(@start_node)
    GL.Vertex3fv(@end_node)
    GL.End()
  end

  def initialize(start_node, end_node)
    @start_node = start_node
    @end_node = end_node
    @node_color = Color::BLACK
    @line_color = Color::BLACK
  end
end

class Cube
  @@vertex = [
    [0.0, 0.0, 0.0],
    [1.0, 0.0, 0.0],
    [1.0, 1.0, 0.0],
    [0.0, 1.0, 0.0],
    [0.0, 0.0, 1.0],
    [1.0, 0.0, 1.0],
    [1.0, 1.0, 1.0],
    [0.0, 1.0, 1.0]
  ]
  @@edge = [
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

  def self.draw(color)
    GL.Begin(GL::LINES)
    GL.Color3dv(color)
    for i in 0..11
      GL.Vertex3dv(@@vertex[@@edge[i][0]])
      GL.Vertex3dv(@@vertex[@@edge[i][1]])
    end
    GL.End()
  end
end

class Sample 
  def axises
    GL.PointSize(5)
    GL.Begin(GL::POINTS)
    GL.Color3dv(Color::BLACK)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.End()

    # blue is x axis
    GL.Begin(GL::LINES)
    GL.Color3dv(Color::BLUE)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(100.0, 0.0, 0.0)
    # red is y axis
    GL.Color3dv(Color::RED)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(0.0, 100.0, 0.0)
    # green is z axis
    GL.Color3dv(Color::GREEN)
    GL.Vertex3f(0.0, 0.0, 0.0)
    GL.Vertex3f(0.0, 0.0, 100.0)
    GL.End()
  end

  def disp()
    puts "disp"
    GL.Clear(GL::COLOR_BUFFER_BIT)

    axises()

    GL.PushMatrix()
    GL.Rotated(@r, 0.0, 1.0, 0.0)
    Cube.draw(Color::BLACK)

    GL.Translated(1.0, 1.0, 1.0)
    GL.Rotated(@r*2, 0.0, 1.0, 0.0)
    Cube.draw(Color::RED)

    GL.PopMatrix()
    GLUT.SwapBuffers()

    @r += 1
    @r = 0 if @r >= 360
  end

  def idle()
    GLUT.PostRedisplay()
  end

  def resize(w, h)
    GL.Viewport(0, 0, w, h)

    GL.MatrixMode(GL::PROJECTION)
    GL.LoadIdentity()
    GLU.Perspective(30.0, w/h, 1.0, 100.0)

    GL.MatrixMode(GL::MODELVIEW)
    GL.LoadIdentity()
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
    puts "in motion #{x} #{y}"
  end

  def keyboard(key, x, y)
    puts "#{key}"
    case key
    when 'q'
      exit()
    when 'a'
      if @rotate_flag
        GLUT.IdleFunc(lambda {})
        @rotate_flag = false
      else
        GLUT.IdleFunc(method(:idle).to_proc())
        @rotate_flag = true
      end
    when 'w'
      GLUT.PostRedisplay()
    when 'j'
      @side += 2.0
      GL.LoadIdentity()
      GLU.LookAt(@side, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
    when 'l'
      @side -= 2.0
      GL.LoadIdentity()
      GLU.LookAt(@side, 4.0, 5.0, 0.0, 0.0, 0.0, 0.0, 1.0, 0.0)
    when '\033' # ESC but It's not \033, and no print ESC
      exit()
    end
  end

  def init()
    @points = []
    @width = 600.0
    @height = 400.0
    @mouse_on_x = 0
    @mouse_on_y = 0
    @r = 0
    @rotate_flag = false
    @side = 4.0

    GLUT.InitWindowPosition(200, 200)
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