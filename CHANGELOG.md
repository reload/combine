# Change Log

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/)
and this project adheres to [Intended Effort Versioning](https://jacobtomlinson.dev/effver/).


## 1.4.1 - [Unreleased]

## [1.4.0] - 2025-01-07

### Added
- Email/password authentication for legacy endpoint.
- Log in using Google Single Signon.
- Allow users to change password (stop-gap measure until Timelord can use Google auth).

### Fixed
- Handle PHPs old BCrypt version.
- Show last month on the first of the month.
- Fix counting of deleted entries.

### Changed
- Invalid token creds results in 403 response, not an anonymous
  response.
- Only admins can see the user list.

## [1.3.1] - 2024-09-25

### Added
- Allow admin to set password for users.

## [1.3.0] - 2024-09-11

### Removed
- Removed `billable_rounded_hours`

## [1.2.2] - 2024-09-10

### Changed
- "Uddannelse/Kursus" is now "Uddannelsesbudget + teamdage".

## [1.2.1] - 2024-08-12

### Fixed
- Use optarg fork in Dockerfile.

## [1.2.0] - 2024-08-12

### Added
- Rounded versions of hours per day and same normalized.

### Changed
- Renamed `billable_rounded_hours` to `rounded_billable_hours`.
  `billable_rounded_hours` kept around for compatibility for the
  moment being.

## [1.1.5] - 2024-07-29

### Fixed
- Use fork of optarg for Crystal 1.13 compatibility.

## [1.1.4] - 2024-07-29

### Fixed
- Pin Github action version of crystal to the same as the built image.

## [1.1.3] - 2024-07-29

### Fixed
- Update to latest Crystal.

## [1.1.2] - 2024-07-29

### Fixed
- Swap from an to date in cleanup.

### Added
- Add logging to cleanup function.

## [1.1.1] - 2024-07-03

### Added
- Rounded hours in totals.

## [1.1.0] - 2024-07-02

### Added
- Syncing rounded hours.
- Reprocess all time entries to add rounded hours.
- Rounded hours in legacy endpoint.

## [1.0.1] - 2024-06-28

### Fixed
- Better caching of objects.
- Added index on spent_at.

## [1.0.0] - 2024-06-28

### Added
- Initial version, with syncing, and the legacy endpoint.

<!-- links -->
[Unreleased]: https://github.com/reload/combine.git/compare/v1.4.0...HEAD
[1.4.0]: https://github.com/reload/combine.git/compare/v1.3.1...v1.4.0
[1.3.1]: https://github.com/reload/combine.git/compare/v1.3.0...v1.3.1
[1.3.0]: https://github.com/reload/combine.git/compare/v1.2.2...v1.3.0
[1.2.2]: https://github.com/reload/combine.git/compare/v1.2.1...v1.2.2
[1.2.1]: https://github.com/reload/combine.git/compare/v1.2.0...v1.2.1
[1.2.0]: https://github.com/reload/combine.git/compare/v1.1.5...v1.2.0
[1.1.5]: https://github.com/reload/combine.git/compare/v1.1.4...v1.1.5
[1.1.4]: https://github.com/reload/combine.git/compare/v1.1.3...v1.1.4
[1.1.3]: https://github.com/reload/combine.git/compare/v1.1.2...v1.1.3
[1.1.2]: https://github.com/reload/combine.git/compare/v1.1.1...v1.1.2
[1.1.1]: https://github.com/reload/combine.git/compare/v1.1.0...v1.1.1
[1.1.0]: https://github.com/reload/combine.git/compare/v1.0.1...v1.1.0
[1.0.1]: https://github.com/reload/combine.git/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/reload/combine.git/releases/tag/v1.0.0
