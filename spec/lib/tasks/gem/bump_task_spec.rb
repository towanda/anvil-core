require 'spec_helper'
require 'tasks/gem/bump_task'
require 'git'
require 'anvil'

describe Gem::BumpTask do
  subject { Gem::BumpTask.new 'major' }

  describe '#task' do
    before  { subject.stub(:read_version).and_return('2.0.0') }

    it 'bumps the version and writes it' do
      expect(subject).to receive(:prepare_repo).and_return(true)
      expect(subject).to receive(:write_version).and_return(true)

      expect(subject.task).to eq('3.0.0')
    end
  end

  describe '#write_version' do
    context 'when persisting' do
      subject { Gem::BumpTask.new 'major', persist: true }
      it 'writes the file and push the changes' do
        expect(subject).to receive(:version_file).with('w+')
        expect(subject).to receive(:commit_and_tag)
      end
    end

    context 'when no persisting' do
      it 'writes the file but does not persist the change in git' do
        expect(subject).to receive(:version_file).with('w+')
        expect(subject).to_not receive(:commit_and_tag)
      end
    end

    after { subject.send :write_version, '2.0.0' }
  end

  describe '#prepare_repo' do
    context 'on a clean repo' do
      before do
        subject.stub(:clean?).and_return(true)
        subject.stub(:git).and_return(double)
      end

      it 'pulls' do
        expect(subject.send(:git)).to receive(:pull)
      end

      after { subject.send :prepare_repo }
    end

    context 'on a dirty repo' do
      before { subject.stub(:clean?).and_return(false) }

      it 'raises RepoNotClean' do
        expect do
          subject.send :prepare_repo
        end.to raise_error(Anvil::RepoNotClean)
      end
    end
  end
end
