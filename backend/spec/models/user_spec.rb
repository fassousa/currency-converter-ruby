# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:transactions).dependent(:destroy) }
  end

  describe 'validations' do
    subject { build(:user) }

    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to allow_value('user@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid_email').for(:email) }
  end

  describe 'Devise modules' do
    it 'includes database_authenticatable' do
      expect(described_class.devise_modules).to include(:database_authenticatable)
    end

    it 'includes registerable' do
      expect(described_class.devise_modules).to include(:registerable)
    end

    it 'includes jwt_authenticatable' do
      expect(described_class.devise_modules).to include(:jwt_authenticatable)
    end

    it 'includes recoverable' do
      expect(described_class.devise_modules).to include(:recoverable)
    end

    it 'includes rememberable' do
      expect(described_class.devise_modules).to include(:rememberable)
    end

    it 'includes validatable' do
      expect(described_class.devise_modules).to include(:validatable)
    end
  end

  describe 'JWT revocation strategy' do
    it 'uses JTIMatcher strategy' do
      expect(described_class.jwt_revocation_strategy).to eq(described_class)
    end

    it 'includes Devise::JWT::RevocationStrategies::JTIMatcher' do
      expect(described_class.ancestors).to include(Devise::JWT::RevocationStrategies::JTIMatcher)
    end
  end

  describe 'callbacks' do
    describe '#set_jti' do
      it 'sets jti before creating a user' do
        user = described_class.new(email: 'test@example.com', password: 'password123')
        expect(user.jti).to be_nil
        user.save!
        expect(user.jti).to be_present
        expect(user.jti).to match(/\A[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}\z/)
      end

      it 'does not override existing jti on updates' do
        user = described_class.create!(email: 'test@example.com', password: 'password123')
        original_jti = user.jti

        user.update!(email: 'updated@example.com')
        expect(user.reload.jti).to eq(original_jti)
      end
    end
  end

  describe 'password encryption' do
    it 'encrypts password on creation' do
      user = described_class.create!(email: 'test@example.com', password: 'password123')
      expect(user.encrypted_password).to be_present
      expect(user.encrypted_password).not_to eq('password123')
    end

    it 'validates password presence on creation' do
      user = described_class.new(email: 'test@example.com')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include("can't be blank")
    end

    it 'validates minimum password length' do
      user = described_class.new(email: 'test@example.com', password: 'short')
      expect(user).not_to be_valid
      expect(user.errors[:password]).to include('is too short (minimum is 6 characters)')
    end

    it 'authenticates with valid password' do
      user = described_class.create!(email: 'test@example.com', password: 'password123')
      expect(user.valid_password?('password123')).to be true
    end

    it 'does not authenticate with invalid password' do
      user = described_class.create!(email: 'test@example.com', password: 'password123')
      expect(user.valid_password?('wrongpassword')).to be false
    end
  end

  describe 'dependent destroy' do
    it 'destroys associated transactions when user is destroyed' do
      user = create(:user)
      transaction = create(:transaction, user: user)

      expect { user.destroy }.to change(Transaction, :count).by(-1)
      expect(Transaction.exists?(transaction.id)).to be false
    end

    it 'destroys multiple transactions when user is destroyed' do
      user = create(:user)
      create_list(:transaction, 3, user: user)

      expect { user.destroy }.to change(Transaction, :count).by(-3)
    end
  end

  describe 'instance methods' do
    let(:user) { create(:user) }

    describe '#transactions' do
      it 'returns empty collection for new user' do
        expect(user.transactions).to be_empty
      end

      it 'returns associated transactions' do
        transaction1 = create(:transaction, user: user)
        transaction2 = create(:transaction, user: user)

        expect(user.transactions).to include(transaction1, transaction2)
        expect(user.transactions.count).to eq(2)
      end

      it 'does not return other users transactions' do
        other_user = create(:user)
        other_transaction = create(:transaction, user: other_user)

        expect(user.transactions).not_to include(other_transaction)
      end
    end
  end

  describe 'uniqueness validation' do
    it 'prevents duplicate emails' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'test@example.com')

      expect(duplicate_user).not_to be_valid
      expect(duplicate_user.errors[:email]).to include('has already been taken')
    end

    it 'is case-insensitive for email uniqueness' do
      create(:user, email: 'test@example.com')
      duplicate_user = build(:user, email: 'TEST@example.com')

      expect(duplicate_user).not_to be_valid
    end
  end
end
