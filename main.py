import streamlit as st

# セッションステートを初期化
if "messages" not in st.session_state:
    st.session_state.messages = []

# タイトルを設定
st.title("グループチャット")

# メッセージ入力欄
message = st.text_area("メッセージを入力してください")

# 送信ボタン
if st.button("送信"):
    st.session_state.messages.append(message)
    st.text_area("", value="", key="output")

# 過去のメッセージを表示
for msg in st.session_state.messages:
    st.text(msg)
