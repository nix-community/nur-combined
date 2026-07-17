#ifndef SCENE_H
#define SCENE_H

typedef enum AtlasTextureKind {
  AtlasTextureKind_Monochrome = 0,
  AtlasTextureKind_Polychrome = 1,
} AtlasTextureKind;

typedef enum BackgroundTag {
  BackgroundTag_Solid = 0,
  BackgroundTag_LinearGradient = 1,
  BackgroundTag_PatternSlash = 2,
} BackgroundTag;

/**
 * The style of a border.
 */
typedef enum BorderStyle {
  /**
   * A solid border.
   */
  BorderStyle_Solid = 0,
  /**
   * A dashed border.
   */
  BorderStyle_Dashed = 1,
} BorderStyle;

/**
 * A color space for color interpolation.
 *
 * References:
 * - <https://developer.mozilla.org/en-US/docs/Web/CSS/color-interpolation-method>
 * - <https://www.w3.org/TR/css-color-4/#typedef-color-space>
 */
typedef enum ColorSpace {
  /**
   * The sRGB color space.
   */
  ColorSpace_Srgb = 0,
  /**
   * The Oklab color space.
   */
  ColorSpace_Oklab = 1,
} ColorSpace;

typedef enum PathRasterizationInputIndex {
  PathRasterizationInputIndex_Vertices = 0,
  PathRasterizationInputIndex_ViewportSize = 1,
} PathRasterizationInputIndex;

typedef enum QuadInputIndex {
  QuadInputIndex_Vertices = 0,
  QuadInputIndex_Quads = 1,
  QuadInputIndex_ViewportSize = 2,
} QuadInputIndex;

typedef enum ShadowInputIndex {
  ShadowInputIndex_Vertices = 0,
  ShadowInputIndex_Shadows = 1,
  ShadowInputIndex_ViewportSize = 2,
} ShadowInputIndex;

typedef enum SpriteInputIndex {
  SpriteInputIndex_Vertices = 0,
  SpriteInputIndex_Sprites = 1,
  SpriteInputIndex_ViewportSize = 2,
  SpriteInputIndex_AtlasTextureSize = 3,
  SpriteInputIndex_AtlasTexture = 4,
} SpriteInputIndex;

typedef enum SurfaceInputIndex {
  SurfaceInputIndex_Vertices = 0,
  SurfaceInputIndex_Surfaces = 1,
  SurfaceInputIndex_ViewportSize = 2,
  SurfaceInputIndex_TextureSize = 3,
  SurfaceInputIndex_YTexture = 4,
  SurfaceInputIndex_CbCrTexture = 5,
} SurfaceInputIndex;

typedef enum UnderlineInputIndex {
  UnderlineInputIndex_Vertices = 0,
  UnderlineInputIndex_Underlines = 1,
  UnderlineInputIndex_ViewportSize = 2,
} UnderlineInputIndex;

/**
 * Represents a length in pixels, the base unit of measurement in the UI framework.
 *
 * `Pixels` is a value type that represents an absolute length in pixels, which is used
 * for specifying sizes, positions, and distances in the UI. It is the fundamental unit
 * of measurement for all visual elements and layout calculations.
 *
 * The inner value is an `f32`, allowing for sub-pixel precision which can be useful for
 * anti-aliasing and animations. However, when applied to actual pixel grids, the value
 * is typically rounded to the nearest integer.
 *
 * # Examples
 *
 * ```
 * use gpui::{Pixels, ScaledPixels};
 *
 * // Define a length of 10 pixels
 * let length = Pixels::from(10.0);
 *
 * // Define a length and scale it by a factor of 2
 * let scaled_length = length.scale(2.0);
 * assert_eq!(scaled_length, ScaledPixels::from(20.0));
 * ```
 */
typedef float Pixels;
/**
 * Represents zero pixels.
 */
#define Pixels_ZERO 0.0
/**
 * The maximum value that can be represented by `Pixels`.
 */
#define Pixels_MAX f32_MAX
/**
 * The minimum value that can be represented by `Pixels`.
 */
#define Pixels_MIN f32_MIN

/**
 * Describes a location in a 2D cartesian space.
 *
 * It holds two public fields, `x` and `y`, which represent the coordinates in the space.
 * The type `T` for the coordinates can be any type that implements `Default`, `Clone`, and `Debug`.
 *
 * # Examples
 *
 * ```
 * # use gpui::Point;
 * let point = Point { x: 10, y: 20 };
 * println!("{:?}", point); // Outputs: Point { x: 10, y: 20 }
 * ```
 */
typedef struct Point_f32 {
  /**
   * The x coordinate of the point.
   */
  float x;
  /**
   * The y coordinate of the point.
   */
  float y;
} Point_f32;

typedef struct Point_f32 PointF;

/**
 * An HSLA color
 */
typedef struct Hsla {
  /**
   * Hue, in a range from 0 to 1
   */
  float h;
  /**
   * Saturation, in a range from 0 to 1
   */
  float s;
  /**
   * Lightness, in a range from 0 to 1
   */
  float l;
  /**
   * Alpha, in a range from 0 to 1
   */
  float a;
} Hsla;

typedef struct AtlasTextureId {
  uint32_t index;
  enum AtlasTextureKind kind;
} AtlasTextureId;

typedef struct TileId {
  uint32_t _0;
} TileId;

/**
 * Represents physical pixels on the display.
 *
 * `DevicePixels` is a unit of measurement that refers to the actual pixels on a device's screen.
 * This type is used when precise pixel manipulation is required, such as rendering graphics or
 * interfacing with hardware that operates on the pixel level. Unlike logical pixels that may be
 * affected by the device's scale factor, `DevicePixels` always correspond to real pixels on the
 * display.
 */
typedef int32_t DevicePixels;

/**
 * Describes a location in a 2D cartesian space.
 *
 * It holds two public fields, `x` and `y`, which represent the coordinates in the space.
 * The type `T` for the coordinates can be any type that implements `Default`, `Clone`, and `Debug`.
 *
 * # Examples
 *
 * ```
 * # use gpui::Point;
 * let point = Point { x: 10, y: 20 };
 * println!("{:?}", point); // Outputs: Point { x: 10, y: 20 }
 * ```
 */
typedef struct Point_DevicePixels {
  /**
   * The x coordinate of the point.
   */
  DevicePixels x;
  /**
   * The y coordinate of the point.
   */
  DevicePixels y;
} Point_DevicePixels;

/**
 * A structure representing a two-dimensional size with width and height in a given unit.
 *
 * This struct is generic over the type `T`, which can be any type that implements `Clone`, `Default`, and `Debug`.
 * It is commonly used to specify dimensions for elements in a UI, such as a window or element.
 */
typedef struct Size_DevicePixels {
  /**
   * The width component of the size.
   */
  DevicePixels width;
  /**
   * The height component of the size.
   */
  DevicePixels height;
} Size_DevicePixels;

/**
 * Represents a rectangular area in a 2D space with an origin point and a size.
 *
 * The `Bounds` struct is generic over a type `T` which represents the type of the coordinate system.
 * The origin is represented as a `Point<T>` which defines the top left corner of the rectangle,
 * and the size is represented as a `Size<T>` which defines the width and height of the rectangle.
 *
 * # Examples
 *
 * ```
 * # use gpui::{Bounds, Point, Size};
 * let origin = Point { x: 0, y: 0 };
 * let size = Size { width: 10, height: 20 };
 * let bounds = Bounds::new(origin, size);
 *
 * assert_eq!(bounds.origin, origin);
 * assert_eq!(bounds.size, size);
 * ```
 */
typedef struct Bounds_DevicePixels {
  /**
   * The origin point of this area.
   */
  struct Point_DevicePixels origin;
  /**
   * The size of the rectangle.
   */
  struct Size_DevicePixels size;
} Bounds_DevicePixels;

typedef struct AtlasTile {
  struct AtlasTextureId texture_id;
  struct TileId tile_id;
  uint32_t padding;
  struct Bounds_DevicePixels bounds;
} AtlasTile;

/**
 * Represents scaled pixels that take into account the device's scale factor.
 *
 * `ScaledPixels` are used to ensure that UI elements appear at the correct size on devices
 * with different pixel densities. When a device has a higher scale factor (such as Retina displays),
 * a single logical pixel may correspond to multiple physical pixels. By using `ScaledPixels`,
 * dimensions and positions can be specified in a way that scales appropriately across different
 * display resolutions.
 */
typedef float ScaledPixels;

/**
 * Describes a location in a 2D cartesian space.
 *
 * It holds two public fields, `x` and `y`, which represent the coordinates in the space.
 * The type `T` for the coordinates can be any type that implements `Default`, `Clone`, and `Debug`.
 *
 * # Examples
 *
 * ```
 * # use gpui::Point;
 * let point = Point { x: 10, y: 20 };
 * println!("{:?}", point); // Outputs: Point { x: 10, y: 20 }
 * ```
 */
typedef struct Point_ScaledPixels {
  /**
   * The x coordinate of the point.
   */
  ScaledPixels x;
  /**
   * The y coordinate of the point.
   */
  ScaledPixels y;
} Point_ScaledPixels;

/**
 * A structure representing a two-dimensional size with width and height in a given unit.
 *
 * This struct is generic over the type `T`, which can be any type that implements `Clone`, `Default`, and `Debug`.
 * It is commonly used to specify dimensions for elements in a UI, such as a window or element.
 */
typedef struct Size_ScaledPixels {
  /**
   * The width component of the size.
   */
  ScaledPixels width;
  /**
   * The height component of the size.
   */
  ScaledPixels height;
} Size_ScaledPixels;

/**
 * Represents a rectangular area in a 2D space with an origin point and a size.
 *
 * The `Bounds` struct is generic over a type `T` which represents the type of the coordinate system.
 * The origin is represented as a `Point<T>` which defines the top left corner of the rectangle,
 * and the size is represented as a `Size<T>` which defines the width and height of the rectangle.
 *
 * # Examples
 *
 * ```
 * # use gpui::{Bounds, Point, Size};
 * let origin = Point { x: 0, y: 0 };
 * let size = Size { width: 10, height: 20 };
 * let bounds = Bounds::new(origin, size);
 *
 * assert_eq!(bounds.origin, origin);
 * assert_eq!(bounds.size, size);
 * ```
 */
typedef struct Bounds_ScaledPixels {
  /**
   * The origin point of this area.
   */
  struct Point_ScaledPixels origin;
  /**
   * The size of the rectangle.
   */
  struct Size_ScaledPixels size;
} Bounds_ScaledPixels;

/**
 * Indicates which region of the window is visible. Content falling outside of this mask will not be
 * rendered. Currently, only rectangular content masks are supported, but we give the mask its own type
 * to leave room to support more complex shapes in the future.
 */
typedef struct ContentMask_ScaledPixels {
  /**
   * The bounds
   */
  struct Bounds_ScaledPixels bounds;
} ContentMask_ScaledPixels;

typedef struct PathVertex_ScaledPixels {
  struct Point_ScaledPixels xy_position;
  struct Point_f32 st_position;
  struct ContentMask_ScaledPixels content_mask;
} PathVertex_ScaledPixels;

/**
 * A color stop in a linear gradient.
 *
 * <https://developer.mozilla.org/en-US/docs/Web/CSS/gradient/linear-gradient#linear-color-stop>
 */
typedef struct LinearColorStop {
  /**
   * The color of the color stop.
   */
  struct Hsla color;
  /**
   * The percentage of the gradient, in the range 0.0 to 1.0.
   */
  float percentage;
} LinearColorStop;

/**
 * A background color, which can be either a solid color or a linear gradient.
 */
typedef struct Background {
  enum BackgroundTag tag;
  enum ColorSpace color_space;
  struct Hsla solid;
  float gradient_angle_or_pattern_height;
  struct LinearColorStop colors[2];
  /**
   * Padding for alignment for repr(C) layout.
   */
  uint32_t pad;
} Background;

typedef struct PathRasterizationVertex {
  struct Point_ScaledPixels xy_position;
  struct Point_f32 st_position;
  struct Background color;
  struct Bounds_ScaledPixels bounds;
} PathRasterizationVertex;

typedef uint32_t DrawOrder;

/**
 * Represents the corners of a box in a 2D space, such as border radius.
 *
 * Each field represents the size of the corner on one side of the box: `top_left`, `top_right`, `bottom_right`, and `bottom_left`.
 */
typedef struct Corners_ScaledPixels {
  /**
   * The value associated with the top left corner.
   */
  ScaledPixels top_left;
  /**
   * The value associated with the top right corner.
   */
  ScaledPixels top_right;
  /**
   * The value associated with the bottom right corner.
   */
  ScaledPixels bottom_right;
  /**
   * The value associated with the bottom left corner.
   */
  ScaledPixels bottom_left;
} Corners_ScaledPixels;

typedef struct Shadow {
  DrawOrder order;
  ScaledPixels blur_radius;
  struct Bounds_ScaledPixels bounds;
  struct Corners_ScaledPixels corner_radii;
  struct ContentMask_ScaledPixels content_mask;
  struct Hsla color;
} Shadow;

typedef struct Underline {
  DrawOrder order;
  uint32_t pad;
  struct Bounds_ScaledPixels bounds;
  struct ContentMask_ScaledPixels content_mask;
  struct Hsla color;
  ScaledPixels thickness;
  uint32_t wavy;
} Underline;

/**
 * Represents the edges of a box in a 2D space, such as padding or margin.
 *
 * Each field represents the size of the edge on one side of the box: `top`, `right`, `bottom`, and `left`.
 *
 * # Examples
 *
 * ```
 * # use gpui::Edges;
 * let edges = Edges {
 *     top: 10.0,
 *     right: 20.0,
 *     bottom: 30.0,
 *     left: 40.0,
 * };
 *
 * assert_eq!(edges.top, 10.0);
 * assert_eq!(edges.right, 20.0);
 * assert_eq!(edges.bottom, 30.0);
 * assert_eq!(edges.left, 40.0);
 * ```
 */
typedef struct Edges_ScaledPixels {
  /**
   * The size of the top edge.
   */
  ScaledPixels top;
  /**
   * The size of the right edge.
   */
  ScaledPixels right;
  /**
   * The size of the bottom edge.
   */
  ScaledPixels bottom;
  /**
   * The size of the left edge.
   */
  ScaledPixels left;
} Edges_ScaledPixels;

typedef struct Quad {
  DrawOrder order;
  enum BorderStyle border_style;
  struct Bounds_ScaledPixels bounds;
  struct ContentMask_ScaledPixels content_mask;
  struct Background background;
  struct Hsla border_color;
  struct Corners_ScaledPixels corner_radii;
  struct Edges_ScaledPixels border_widths;
} Quad;

/**
 * A data type representing a 2 dimensional transformation that can be applied to an element.
 */
typedef struct TransformationMatrix {
  /**
   * 2x2 matrix containing rotation and scale,
   * stored row-major
   */
  float rotation_scale[2][2];
  /**
   * translation vector
   */
  float translation[2];
} TransformationMatrix;

typedef struct MonochromeSprite {
  DrawOrder order;
  uint32_t pad;
  struct Bounds_ScaledPixels bounds;
  struct ContentMask_ScaledPixels content_mask;
  struct Hsla color;
  struct AtlasTile tile;
  struct TransformationMatrix transformation;
} MonochromeSprite;

typedef struct PolychromeSprite {
  DrawOrder order;
  uint32_t pad;
  bool grayscale;
  float opacity;
  struct Bounds_ScaledPixels bounds;
  struct ContentMask_ScaledPixels content_mask;
  struct Corners_ScaledPixels corner_radii;
  struct AtlasTile tile;
} PolychromeSprite;

typedef struct PathSprite {
  struct Bounds_ScaledPixels bounds;
} PathSprite;

typedef struct SurfaceBounds {
  struct Bounds_ScaledPixels bounds;
  struct ContentMask_ScaledPixels content_mask;
} SurfaceBounds;

#endif  /* SCENE_H */
