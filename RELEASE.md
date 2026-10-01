# Release Checklist

## Pre-release Steps

1. **Update Version**
   - Edit `VERSION` file with new version number
   - Update version comment in `Package.swift`
   - Update version in `README.md` CocoaPods section

2. **Update Dependencies**
   - Ensure `HyperSDK` version is correct in:
     - `Package.swift`
     - `BBPSSDK.podspec`
   - Check `Sources/BBPSSDK/BBPSService.podspec` for binary release version

3. **Validation**
   ```bash
   # Validate CocoaPods spec
   pod spec lint BBPSSDK.podspec --allow-warnings
   
   # Build with SPM
   swift build
   
   # Test if possible
   swift test
   ```

## Release Steps

1. **Commit Changes**
   ```bash
   git add -A
   git commit -m "Bump version to X.Y.Z"
   ```

2. **Tag Release**
   ```bash
   git tag -a vX.Y.Z -m "Release X.Y.Z"
   git push origin vX.Y.Z
   ```

3. **Publish to CocoaPods** (if publishing to trunk)
   ```bash
   pod trunk push BBPSSDK.podspec
   ```

4. **Verify Installation**
   - Test SPM integration with new tag
   - Test CocoaPods integration: `pod install` with new version

## Post-release

- Update CHANGELOG if maintained
- Notify stakeholders
- Monitor for issues

## Version Format

Follow semantic versioning: `MAJOR.MINOR.PATCH`
- MAJOR: Breaking changes
- MINOR: New features, backwards compatible
- PATCH: Bug fixes
