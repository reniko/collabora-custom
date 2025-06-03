name: Build and Push to GHCR

on:
  push:
    branches: [ "main" ]
  pull_request:
    branches: [ "main" ]
  workflow_dispatch:
  # Automatischer Trigger bei Upstream-Änderungen
  schedule:
    # Läuft täglich um 6:00 UTC
    - cron: '0 6 * * *'

env:
  IMAGE_NAME: ghcr.io/${{ github.repository_owner }}/collabora-locale
  UPSTREAM_IMAGE: collabora/code

jobs:
  # Job zur Überprüfung von Upstream-Updates
  check-upstream:
    runs-on: ubuntu-latest
    outputs:
      needs-update: ${{ steps.check.outputs.needs-update }}
      upstream-digest: ${{ steps.check.outputs.upstream-digest }}
    steps:
      - name: Check for upstream updates
        id: check
        run: |
          # Aktueller Digest des Upstream-Images
          UPSTREAM_DIGEST=$(docker manifest inspect ${{ env.UPSTREAM_IMAGE }}:latest | jq -r '.config.digest')
          echo "upstream-digest=$UPSTREAM_DIGEST" >> $GITHUB_OUTPUT
          
          # Prüfe ob unser letztes Build auf einem anderen Digest basiert
          LAST_BUILD_DIGEST=$(gh api repos/${{ github.repository }}/actions/variables/LAST_UPSTREAM_DIGEST --jq '.value' 2>/dev/null || echo "")
          
          if [[ "$UPSTREAM_DIGEST" != "$LAST_BUILD_DIGEST" ]] || [[ "${{ github.event_name }}" != "schedule" ]]; then
            echo "needs-update=true" >> $GITHUB_OUTPUT
            echo "🔄 Upstream update detected or manual trigger"
          else
            echo "needs-update=false" >> $GITHUB_OUTPUT
            echo "✅ No upstream updates needed"
          fi
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

  build:
    runs-on: ubuntu-latest
    needs: check-upstream
    # Nur bauen wenn Update nötig ist
    if: needs.check-upstream.outputs.needs-update == 'true'
    
    steps:
      - name: Checkout repo
        uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to GHCR
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ${{ env.IMAGE_NAME }}:latest
            ${{ env.IMAGE_NAME }}:${{ github.run_number }}
            ${{ env.IMAGE_NAME }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
          # Multi-platform build (optional)
          platforms: linux/amd64,linux/arm64

      - name: Update upstream digest variable
        if: success()
        run: |
          gh api repos/${{ github.repository }}/actions/variables/LAST_UPSTREAM_DIGEST \
            -X PATCH \
            -f name=LAST_UPSTREAM_DIGEST \
            -f value="${{ needs.check-upstream.outputs.upstream-digest }}" \
            2>/dev/null || \
          gh api repos/${{ github.repository }}/actions/variables \
            -f name=LAST_UPSTREAM_DIGEST \
            -f value="${{ needs.check-upstream.outputs.upstream-digest }}"
        env:
          GH_TOKEN: ${{ secrets.GITHUB_TOKEN }}

      - name: Test image
        run: |
          docker run --rm --detach --name test-container \
            -p 9980:9980 \
            ${{ env.IMAGE_NAME }}:latest
          
          # Warte auf Startup
          sleep 30
          
          # Einfacher Health Check
          curl -f http://localhost:9980/hosting/discovery || exit 1
          
          # Container stoppen
          docker stop test-container
