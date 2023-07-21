require './spec/sizing_support.rb'
require './app/asset_workspace/sprite_sizing.rb'

include VP::Helpers

describe "sizing" do
  # Setup and assumptions
  let(:calculator) { SpriteSize::Calculator.new(asset, frame_rect) }
  let(:frame_rect) { quick_rect(15, 20, 480, 360) }

  # These vary, or are linked to things that vary
  let(:asset) { Asset.new(asset_dimensions) }
  let(:zoom) { initial_zoom }

  # Checking Answers
  let(:initial_zoom) { calculator.default_zoom }
  let(:initial_zoom_i) { initial_zoom.to_f.to_i }

  # Checking Result Answers
  let(:input_offset) { dimensions(0,0) }
  let(:result) { calculator.result(zoom: zoom, input_offset: input_offset) }
  let(:size) { result.dimensions }
  let(:position) { result.bounds.position }
  let(:source) { result.source.dimensions }
  let(:output_offset) { result.source.bounds.position }

  context "circle" do
    let(:asset_dimensions) { dimensions(80, 80) }
    context "default zoom" do
      it { expect(initial_zoom_i).to eq(4) }
      it { expect(size).to eq(dimensions(320, 320)) }
      it { expect(position).to eq(dimensions(15 + 80, 20 + 20)) }
      it { expect(source).to eq(asset.dimensions) }
      # not worth it it { expect(position).to eq(nwi) }
    end

    context "zoom in" do
      let(:zoom) { fraction(5,1) }
      it { expect(size).to eq(dimensions(400, 360)) }
      it { expect(source).to eq(dimensions(80, 72)) }
      # not worth it it { expect(position).to eq(nwi) }

      describe "offset" do
        context "just see the upper right corner" do

        end
      end
    end

    context "zoom out" do
      let(:zoom) { fraction(3,1) }
      it { expect(size).to eq(dimensions(240, 240)) }
      it { expect(source).to eq(dimensions(80, 80)) }
      # not worth it it { expect(position).to eq(nwi) }

      context "offset", :skip do
        # testing stuff with offsets
      end
    end
  end

  context "time_fantasy tileset" do
    let(:asset_dimensions) { dimensions(576, 416) }

    context "default zoom" do
      it { expect(initial_zoom).to eq(fraction(1,2)) }
      it { expect(size).to eq(dimensions(288, 208)) }
      it { expect(position).to eq(dimensions(15 + (480 - 288)/2, 20 + (360 - 208)/2)) }
      it { expect(source).to eq(asset.dimensions) }
    end

    context "zoom in" do
      let(:zoom) { fraction(1,1) }
      it { expect(size).to eq(dimensions(480, 360)) }
      it { expect(source).to eq(dimensions(480, 360)) }
      it { expect(position).to eq(dimensions(15, 20)) }

      context "offset", :skip do
        # testing stuff with offsets
      end
    end

    context "zoom out" do
      let(:zoom) { fraction(1,4) }
      it { expect(size).to eq(dimensions(576/4, 416/4)) }
      it { expect(source).to eq(asset.dimensions) }
      # not worth it it { expect(position).to eq(nwi) }

      context "offset", :skip do
        # testing stuff with offsets
      end
    end
  end
end
