class_name Climb

const METER: float = 12.0
const SUMMIT_METERS: float = 2000.0
const MOUNTAIN_WIDTH: float = 384.0
const CENTER_X: float = MOUNTAIN_WIDTH / 2.0
const START_Y: float = 0.0
const SUMMIT_Y: float = START_Y - SUMMIT_METERS * METER
const MARGIN: float = 240.0
const TOP_Y: float = SUMMIT_Y - MARGIN
const BOTTOM_Y: float = START_Y + MARGIN
const WALL_WIDTH: float = 16.0
const ROCK_START_METERS: float = 700.0
const SNOW_START_METERS: float = 1400.0

static func y_at(meters: float) -> float:
	return START_Y - meters *  METER

static func height_at(y: float) -> float:
	return clampf((START_Y - y) / METER, 0.0, SUMMIT_METERS)
